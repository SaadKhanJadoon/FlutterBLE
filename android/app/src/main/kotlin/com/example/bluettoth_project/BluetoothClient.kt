package com.example.bluettoth_project

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresPermission
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.util.*

class BluetoothClient : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private var serverSocket: BluetoothServerSocket? = null
    private var connectionStatus: String = "Disconnected"
    private var isListening = false
    private var socket: BluetoothSocket? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.bluetooth/client")
        channel.setMethodCallHandler(this)
        Log.d("BluetoothClient", "MethodChannel set up")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.S)
    @RequiresPermission(anyOf = [Manifest.permission.BLUETOOTH_CONNECT])
    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("BluetoothClient", "Method call received: ${call.method}")
        if (call.method == "startClient") {
            startClient(result)
        }else if (call.method == "stopClient") {
            closeSockets(result)
        } else {
            result.notImplemented()
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    @RequiresPermission(anyOf = [Manifest.permission.BLUETOOTH_CONNECT])
    private fun startClient(result: Result) {
        if (isListening) {
            // Already listening, ignore the new start attempt
            result.success("Already listening for connections")
            return
        }

        isListening = true
        Thread {
            try {
                serverSocket =
                    bluetoothAdapter.listenUsingRfcommWithServiceRecord("BluetoothServer", MY_UUID)
                socket = serverSocket?.accept()

                socket?.let {
                    connectionStatus = "Connected to ${it.remoteDevice.name}"
                    Log.d("BluetoothClient", "Connected to ${it.remoteDevice.name}")

                    // Read data from the server
                    val inputStream = it.inputStream
                    val buffer = ByteArray(1024)
                    var bytes: Int

                    while (it.isConnected) {
                        bytes = inputStream.read(buffer)
                        if (bytes > 0) {
                            val data = String(buffer, 0, bytes)
                            Log.d("BluetoothClient Native", "Received data: $data")
                            Handler(Looper.getMainLooper()).post {
                                channel.invokeMethod("receiveData", data)
                                Log.d("BluetoothClient Native", "Data sent to Flutter: $data")
                            }
                        }
                    }
                }
            } catch (e: IOException) {
                Log.e("BluetoothClient", "Socket's accept() method failed ${e.message}")
                connectionStatus = "Failed to connect"
            } finally {
                isListening = false
                socket?.close()
                Log.d("BluetoothClient", "Socket closed")
            }
            Handler(Looper.getMainLooper()).post {
                result.success(connectionStatus)
            }
        }.start()
    }

    private fun closeSockets(result: Result) {
        try {
            socket?.close()
            serverSocket?.close()
            result.success("Socket Closed")
        } catch (e: IOException) {
            result.error("closeSockets", "Failed to close sockets", e)
            Log.e("BluetoothClient", "Could not close sockets", e)
        }
    }
}
