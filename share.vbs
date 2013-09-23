dim pub, prv, idx

ICSSC_DEFAULT         = 0
CONNECTION_PUBLIC     = 0
CONNECTION_PRIVATE    = 1
CONNECTION_ALL        = 2

set NetSharingManager = Wscript.CreateObject("HNetCfg.HNetShare.1")

wscript.echo "No.   Name" & vbCRLF & "------------------------------------------------------------------"
idx = 0
set Connections = NetSharingManager.EnumEveryConnection
for each Item in Connections
	idx = idx + 1
	set Connection = NetSharingManager.INetSharingConfigurationForINetConnection(Item)
	set Props = NetSharingManager.NetConnectionProps(Item)
	szMsg = CStr(idx) & "     " & Props.Name
	wscript.echo szMsg
next
wscript.echo "------------------------------------------------------------------"
wscript.stdout.write "Select public connection(for internet access) No.: "
pub = cint(wscript.stdin.readline)
wscript.stdout.write "Select private connection(for share users) No.: "
prv = cint(wscript.stdin.readline)
if pub = prv then
  wscript.echo "Error: Public can't be same as private!"
  wscript.quit
end if

idx = 0
set Connections = NetSharingManager.EnumEveryConnection
for each Item in Connections
	idx = idx + 1
	set Connection = NetSharingManager.INetSharingConfigurationForINetConnection(Item)
	set Props = NetSharingManager.NetConnectionProps(Item)
	if idx = prv then Connection.EnableSharing CONNECTION_PRIVATE
	if idx = pub then Connection.EnableSharing CONNECTION_PUBLIC
next
