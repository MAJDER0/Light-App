using InTheHand.Net;
using InTheHand.Net.Bluetooth;
using InTheHand.Net.Sockets;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;

namespace Light_App.Controllers
{
    public class BluetoothController : Controller
    {
        private static BluetoothClient _client;
        private static bool _isLightOn = false;

        // Endpoint for connecting to a Bluetooth device
        [HttpPost]
        public ActionResult ConnectToDevice(string deviceAddress)
        {
            try
            {
                BluetoothAddress address = BluetoothAddress.Parse(deviceAddress);
                _client = new BluetoothClient();
                _client.Connect(address, BluetoothService.SerialPort);
                return Json(new { success = true });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Endpoint for discovering available devices
        [HttpGet]
        public ActionResult<IEnumerable<BluetoothDevice>> LookForDevices()
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
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Endpoint for toggling the light
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
                return Json(new { success = false, message = ex.Message });
            }
        }


        [HttpGet]
        public ActionResult CheckConnectionStatus()
        {
            try
            {
                bool isConnected = _client != null && _client.Connected;
                return Json(new { success = true, isConnected });
            }
            catch (Exception ex)
            {
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
