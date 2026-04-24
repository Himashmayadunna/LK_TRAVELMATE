package com.example.lk_travelmate

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

	private var methodChannel: MethodChannel? = null
	private var speechRecognizer: SpeechRecognizer? = null
	private var isListening: Boolean = false
	private var lastRecognizedText: String = ""
	private var pendingLocaleForPermission: String? = null
	private var pendingResultForPermission: MethodChannel.Result? = null

	companion object {
		private const val REQUEST_MIC_PERMISSION = 1001
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		methodChannel = MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"lk_travelmate/mlkit_speech"
		)
		methodChannel?.setMethodCallHandler(this)
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"startListening" -> {
				val locale = call.argument<String>("locale") ?: "en-US"
				startListening(locale, result)
			}

			"stopListening" -> {
				stopListening(result)
			}

			"isListening" -> {
				result.success(isListening)
			}

			else -> result.notImplemented()
		}
	}

	private fun startListening(locale: String, result: MethodChannel.Result) {
		if (!SpeechRecognizer.isRecognitionAvailable(this)) {
			result.error("unavailable", "Speech recognition service is unavailable on this device.", null)
			return
		}

		val hasMicPermission = ContextCompat.checkSelfPermission(
			this,
			Manifest.permission.RECORD_AUDIO
		) == PackageManager.PERMISSION_GRANTED

		if (!hasMicPermission) {
			pendingLocaleForPermission = locale
			pendingResultForPermission = result
			ActivityCompat.requestPermissions(
				this,
				arrayOf(Manifest.permission.RECORD_AUDIO),
				REQUEST_MIC_PERMISSION
			)
			return
		}

		if (speechRecognizer == null) {
			speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
			speechRecognizer?.setRecognitionListener(object : RecognitionListener {
				override fun onReadyForSpeech(params: Bundle?) = Unit

				override fun onBeginningOfSpeech() = Unit

				override fun onRmsChanged(rmsdB: Float) = Unit

				override fun onBufferReceived(buffer: ByteArray?) = Unit

				override fun onEndOfSpeech() {
					isListening = false
				}

				override fun onError(error: Int) {
					isListening = false
				}

				override fun onResults(results: Bundle?) {
					val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
					if (!matches.isNullOrEmpty()) {
						lastRecognizedText = matches[0]
						runOnUiThread {
							methodChannel?.invokeMethod(
								"onFinalResult",
								mapOf("text" to lastRecognizedText)
							)
						}
					}
					isListening = false
				}

				override fun onPartialResults(partialResults: Bundle?) {
					val partialMatches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
					if (!partialMatches.isNullOrEmpty()) {
						lastRecognizedText = partialMatches[0]
						runOnUiThread {
							methodChannel?.invokeMethod(
								"onPartialResult",
								mapOf("text" to lastRecognizedText)
							)
						}
					}
				}

				override fun onEvent(eventType: Int, params: Bundle?) = Unit
			})
		}

		val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
			putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
			putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
			putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
			putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
			putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, locale)
			putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
		}

		try {
			lastRecognizedText = ""
			speechRecognizer?.cancel()
			speechRecognizer?.startListening(intent)
			isListening = true
			result.success(null)
		} catch (e: Exception) {
			isListening = false
			result.error("start_failed", e.message, null)
		}
	}

	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)

		if (requestCode != REQUEST_MIC_PERMISSION) {
			return
		}

		val locale = pendingLocaleForPermission
		val callback = pendingResultForPermission
		pendingLocaleForPermission = null
		pendingResultForPermission = null

		if (callback == null || locale == null) {
			return
		}

		val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
		if (!granted) {
			callback.error("permission_denied", "Microphone permission is required.", null)
			return
		}

		startListening(locale, callback)
	}

	private fun stopListening(result: MethodChannel.Result) {
		try {
			if (isListening) {
				speechRecognizer?.stopListening()
			} else {
				speechRecognizer?.cancel()
			}
			isListening = false
			result.success(lastRecognizedText)
		} catch (e: Exception) {
			result.error("stop_failed", e.message, null)
		}
	}

	override fun onDestroy() {
		methodChannel?.setMethodCallHandler(null)
		methodChannel = null
		speechRecognizer?.cancel()
		speechRecognizer?.destroy()
		speechRecognizer = null
		super.onDestroy()
	}
}
