package com.example.safetrek_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.safetrek_project/power_button"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter()
                    filter.addAction(Intent.ACTION_SCREEN_OFF)
                    filter.addAction(Intent.ACTION_SCREEN_ON)
                    // Sử dụng applicationContext để đăng ký receiver
                    this@MainActivity.applicationContext.registerReceiver(powerButtonReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    try {
                        this@MainActivity.applicationContext.unregisterReceiver(powerButtonReceiver)
                    } catch (e: Exception) {
                        // Receiver might not be registered or already unregistered
                    }
                    eventSink = null
                }
            }
        )
    }

    private val powerButtonReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_SCREEN_OFF || intent?.action == Intent.ACTION_SCREEN_ON) {
                eventSink?.success(intent.action)
            }
        }
    }
}
