package com.liquidhive.openair

import android.content.Context
import android.media.AudioManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "openair/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "useLoudspeaker" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    audioManager.mode = AudioManager.MODE_NORMAL

                    val hasHeadset = audioManager.isBluetoothA2dpOn ||
                        audioManager.isBluetoothScoOn ||
                        audioManager.isWiredHeadsetOn ||
                        audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).any {
                            it.type == android.media.AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                                it.type == android.media.AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
                                it.type == android.media.AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                                it.type == android.media.AudioDeviceInfo.TYPE_BLUETOOTH_SCO
                        }

                    // Only force the built-in speaker when no headset/Bluetooth is connected.
                    audioManager.isSpeakerphoneOn = !hasHeadset
                    result.success(!hasHeadset)
                }
                else -> result.notImplemented()
            }
        }
    }
}