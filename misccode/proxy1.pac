// Automatic proxy configuration for Solectron RTP clients on
// 47.143.208.0/20 or 47.23.32.0/20 *without* Extranet/Contivity
// access to the Solectron intranet.
//
// This configuration uses Nortel pipes for Internet access.

function FindProxyForURL(url, host)
{

// use underground gateway to reach Solectron intranet
if (dnsDomainIs(host, ".slr.com"))
	return "PROXY 47.143.208.133:8009";

if (isInNet(host, "10.0.0.0",    "255.0.0.0"  ) ||
	isInNet(host, "158.116.0.0", "255.255.0.0") ||
	isInNet(host, "167.210.0.0", "255.255.0.0")
	)
	return "PROXY 47.143.208.133:8009";

// use direct access to everything else, including the Internet
// via Nortel proxy-less firewall

return "DIRECT";
}
