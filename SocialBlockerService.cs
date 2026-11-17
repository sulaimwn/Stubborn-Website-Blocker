using System;
using System.ServiceProcess;
using System.Diagnostics;
using System.IO;
using System.Threading;

namespace SocialBlockerService
{
    public partial class SocialBlockerService : ServiceBase
    {
        private Timer watchdogTimer;
        private const string InstallDir = "C:\\Program Files\\SocialBlocker";
        private const string BlockScriptPath = InstallDir + "\\block_hosts.ps1";

        public SocialBlockerService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            // Start the watchdog timer to run every 5 minutes
            watchdogTimer = new Timer(WatchdogCallback, null, TimeSpan.Zero, TimeSpan.FromMinutes(5));
            
            // Apply initial block
            ApplyBlock();
        }

        protected override void OnStop()
        {
            watchdogTimer?.Dispose();
        }

        private void WatchdogCallback(object state)
        {
            try
            {
                // Check if service is running (this is redundant but ensures persistence)
                
                // Apply the block
                ApplyBlock();
                
                // Check if the install directory still exists
                if (!Directory.Exists(InstallDir))
                {
                    Directory.CreateDirectory(InstallDir);
                }
                
                // Copy current files if they're missing
                string currentPath = System.Reflection.Assembly.GetExecutingAssembly().Location;
                string serviceName = Path.GetFileName(currentPath);
                if (!File.Exists(InstallDir + "\\" + serviceName))
                {
                    File.Copy(currentPath, InstallDir + "\\" + serviceName, true);
                }
                
                // Copy block script if it exists
                if (File.Exists(BlockScriptPath))
                {
                    // Run the block script
                    RunPowerShellScript(BlockScriptPath);
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                EventLog.WriteEntry("SocialBlockerService", "Error in watchdog: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void ApplyBlock()
        {
            try
            {
                if (File.Exists(BlockScriptPath))
                {
                    RunPowerShellScript(BlockScriptPath);
                }
                else
                {
                    // If block script doesn't exist, try to run from install directory
                    string scriptPath = InstallDir + "\\block_hosts.ps1";
                    if (File.Exists(scriptPath))
                    {
                        RunPowerShellScript(scriptPath);
                    }
                }
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("SocialBlockerService", "Error applying block: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void RunPowerShellScript(string scriptPath)
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = "-ExecutionPolicy Bypass -File \"" + scriptPath + "\"";
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            
            using (Process process = Process.Start(startInfo))
            {
                process.WaitForExit();
            }
        }
    }
}
