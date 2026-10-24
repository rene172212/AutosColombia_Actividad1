using System;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Windows.Forms;

internal static class IniciarAutosColombia
{
    private static int Main()
    {
        string exeDirectory = AppDomain.CurrentDomain.BaseDirectory;
        string nestedProject = Path.Combine(exeDirectory, "AutosColombia");
        string project = Directory.Exists(Path.Combine(nestedProject, "backend"))
            ? nestedProject
            : exeDirectory;
        string backend = Path.Combine(project, "backend");
        string frontend = Path.Combine(project, "frontend");
        string python = Path.Combine(backend, ".venv", "Scripts", "python.exe");

        if (!File.Exists(python))
        {
            MessageBox.Show(
                "No se encontró el entorno virtual del backend:\n" + python,
                "Autos Colombia",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }

        if (!File.Exists(Path.Combine(frontend, "package.json")) ||
            !Directory.Exists(Path.Combine(frontend, "node_modules")))
        {
            MessageBox.Show(
                "No se encontró frontend/node_modules. Instala las dependencias del proyecto antes de iniciar.",
                "Autos Colombia",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }

        try
        {
            if (!IsPortListening(8000))
                StartConsole(backend, "Autos Colombia - Backend", ".venv\\Scripts\\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000");

            if (!IsPortListening(4200))
                StartConsole(frontend, "Autos Colombia - Frontend", "npm.cmd start -- --host 127.0.0.1 --port 4200");

            bool backendReady = WaitForHttp("http://127.0.0.1:8000/health", 90000);
            bool frontendReady = WaitForHttp("http://127.0.0.1:4200/", 90000);

            if (!backendReady || !frontendReady)
            {
                string message = "No fue posible confirmar el inicio de todos los servicios. Revisa las ventanas de consola.";
                if (!backendReady) message += "\nBackend: http://127.0.0.1:8000/health";
                if (!frontendReady) message += "\nFrontend: http://127.0.0.1:4200/";
                MessageBox.Show(message, "Autos Colombia", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return 1;
            }

            Process.Start(new ProcessStartInfo("http://127.0.0.1:4200/") { UseShellExecute = true });
            return 0;
        }
        catch (Exception error)
        {
            MessageBox.Show(
                "No se pudieron iniciar los servicios.\n" + error.Message,
                "Autos Colombia",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }
    }

    private static void StartConsole(string workingDirectory, string title, string command)
    {
        string arguments = "/k \"title " + title + " & " + command + "\"";
        Process.Start(new ProcessStartInfo("cmd.exe", arguments)
        {
            WorkingDirectory = workingDirectory,
            UseShellExecute = true,
            WindowStyle = ProcessWindowStyle.Normal
        });
    }

    private static bool IsPortListening(int port)
    {
        try
        {
            using (TcpClient client = new TcpClient())
            {
                IAsyncResult connection = client.BeginConnect("127.0.0.1", port, null, null);
                bool connected = connection.AsyncWaitHandle.WaitOne(300);
                if (connected)
                {
                    try { client.EndConnect(connection); }
                    catch (SocketException) { return false; }
                }
                return connected && client.Connected;
            }
        }
        catch (SocketException)
        {
            return false;
        }
    }

    private static bool WaitForHttp(string address, int timeoutMilliseconds)
    {
        Stopwatch elapsed = Stopwatch.StartNew();
        while (elapsed.ElapsedMilliseconds < timeoutMilliseconds)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(address);
                request.Timeout = 1500;
                request.ReadWriteTimeout = 1500;
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                    if ((int)response.StatusCode >= 200 && (int)response.StatusCode < 400)
                        return true;
            }
            catch (WebException) { }

            Thread.Sleep(750);
        }
        return false;
    }
}
