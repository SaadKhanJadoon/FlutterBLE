package com.example.bluettoth_project

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
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

class BluetoothServer : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    private val MY_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private var connectionStatus: String = "Disconnected"
    private var isConnecting = false
    private var socket: BluetoothSocket? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.bluetooth/server")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.S)
    @RequiresPermission(anyOf = [Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN])
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connectToDevice" -> {
                val address: String? = call.argument("address")
                if (address != null) {
                    connectToDevice(address, result)
                } else {
                    result.error("INVALID_ADDRESS", "Address is null", null)
                }
            }

            "sendData" -> {
                val data: String? = call.argument("data")
                if (data != null) {
                    sendData(data, result)
                } else {
                    result.error("INVALID_DATA", "Data is null", null)
                }
            }

            else -> result.notImplemented()
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    @RequiresPermission(anyOf = [Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN])
    private fun connectToDevice(address: String, result: Result) {
        if (isConnecting) {
            // Already connecting, ignore the new connection attempt
            result.success("Already connecting to a device")
            return
        }

        isConnecting = true
        val device: BluetoothDevice = bluetoothAdapter.getRemoteDevice(address)
        Thread {
            try {
                socket = device.createRfcommSocketToServiceRecord(MY_UUID)
                bluetoothAdapter.cancelDiscovery()
                socket?.connect()
                connectionStatus = "Connected to ${device.name}"
            } catch (e: IOException) {
                Log.d("BluetoothServer", "Could not connect to the device", e)
                connectionStatus = "Failed to connect"
                socket?.close()  // Close the socket if connection failed
                socket = null
            } finally {
                isConnecting = false
            }
            Handler(Looper.getMainLooper()).post {
                result.success(connectionStatus)
            }
        }.start()
    }

    private fun sendData(data: String, result: Result) {
        Thread {
            try {
                socket?.outputStream?.write(data.toByteArray())
                Handler(Looper.getMainLooper()).post {
                    result.success("Data sent")
                }
            } catch (e: IOException) {
                Log.d("BluetoothServer", "Failed to send data", e)
                Handler(Looper.getMainLooper()).post {
                    result.error("SEND_FAILED", "Failed to send data", e)
                }
            }
        }.start()
    }
}
