using InTheHand.Net;
using InTheHand.Net.Bluetooth;
using InTheHand.Net.Sockets;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;

namespace Light_App.Controllers
{
    public class BluetoothController : Controller
    {
        private BluetoothClient _client;
        private bool _isLightOn = false;
        private IConfiguration _configuration;

        public BluetoothController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        // Endpoint for connecting to a Bluetooth device
        [HttpPost]
        public ActionResult ConnectToDevice(string deviceAddress)
        {
            try
            {
                BluetoothAddress address = BluetoothAddress.Parse(deviceAddress);
                _client = new BluetoothClient();
                _client.Connect(address, BluetoothService.SerialPort);
                // Connection successful
                return Json(new { success = true });
            }
            catch (Exception ex)
            {
                // Error connecting to device
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Endpoint for sending commands to the connected device
        [HttpPost]
        public ActionResult ToggleLight()
        {
            try
            {
                if (_client != null && _client.Connected)
                {
                    _isLightOn = !_isLightOn;
                    byte[] command = _isLightOn ? new byte[] { 1 } : new byte[] { 0 };
                    _client.GetStream().Write(command, 0, command.Length);
                    return Json(new { success = true, lightStatus = _isLightOn });
                }
                else
                {
                    return Json(new { success = false, message = "Not connected to any device." });
                }
            }
            catch (Exception ex)
            {
                // Error sending command
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Endpoint for disconnecting from the Bluetooth device
        [HttpPost]
        public ActionResult Disconnect()
        {
            try
            {
                if (_client != null && _client.Connected)
                {
                    _client.Close();
                    return Json(new { success = true });
                }
                else
                {
                    return Json(new { success = false, message = "Not connected to any device." });
                }
            }
            catch (Exception ex)
            {
                // Error disconnecting
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Endpoint for looking for available devices
        [HttpGet]
        public ActionResult LookForDevices()
        {
            try
            {
                List<BluetoothDevice> devices = new List<BluetoothDevice>();

                using (BluetoothClient client = new BluetoothClient())
                {
                    BluetoothDeviceInfo[] infos = client.DiscoverDevices();
                    foreach (BluetoothDeviceInfo info in infos)
                    {
                        devices.Add(new BluetoothDevice { Name = info.DeviceName, Address = info.DeviceAddress.ToString() });
                    }
                }

                return Json(new { success = true, devices });
            }
            catch (Exception ex)
            {
                // Error discovering devices
                return Json(new { success = false, message = ex.Message });
            }
        }
    }

    public class BluetoothDevice
    {
        public string Name { get; set; }
        public string Address { get; set; }
    }
}
