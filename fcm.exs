Mix.install(
  [
    {:pigeon, "~> 2.0.0-rc.2"},
    {:jason, "~> 1.3"}

  ],
  verbose: true
)

# Read the service account JSON
{:ok, service_account_json} = File.read("service-account.json")

# Initialize Goth with the service account JSON
{:ok, _pid} = Goth.start_link(name: MyApp.Goth, source: service_account_json)

# Configure options for FCM using a service account JSON
opts = [
  adapter: Pigeon.FCM,
  project_id: "webtrit-app",
  auth: MyApp.Goth, # Replace with your configured Goth worker
  service_account_json: File.read!("service-account.json")
]

# Start the FCM dispatcher
{:ok, pid} = Pigeon.Dispatcher.start_link(opts)

# Prepare the data payload
data = %{
  handleType: "number",
  handleValue: "event_call[:caller]",
  displayName: "event_call[:caller_display_name]",
  hasVideo: "false",
  callId: "call_id"
}

# Replace "your_device_token_here" with the actual FCM token for the target device
device_token = "csHC5mH0QGqtaaSv_CCv10:APA91bFmNtAjP7e4J1yV23_jUfKaWTnhAU3z7JLrSDy5Fy56ZyFCPD61hduy7icQE29uyAPKRDSThkqS0GkCsOo0T6GAEG5-o6kim9IYKV87BJj_f8dxlsw" # <--- Insert token here

# Create a new notification for the target device
notification = Pigeon.FCM.Notification.new({:token, device_token}, nil, data)

# Set additional options, like priority and TTL, for the notification
notification = %{
  notification
  | android: %{
      priority: :high,
      ttl: "0s"
    }
}

# Send the notification
Pigeon.push(pid, notification)
