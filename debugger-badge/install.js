(function()
{
	var flashvars = {};
	flashvars.airversion = '2.0';
	flashvars.appname = 'SWFWire Debugger';
	flashvars.appurl = 'https://github.com/downloads/magicalhobo/SWFWire/SWFWireDebugger-0.4.14.air';
	flashvars.imageurl = 'debugger-badge/logo.png';
	flashvars.appid = 'SWFWireDebugger';
	flashvars.appversion = '0.4.14';
	flashvars.hidehelp = 'true';
	flashvars.skiptransition = 'false';
	flashvars.titlecolor = '#ffffff';
	flashvars.buttonlabelcolor = '#ffffff';
	flashvars.appnamecolor = '#ffffff';


	var params = {};
	params.wmode = 'transparent';
	params.menu = 'false';
	params.quality = 'high';

	var attributes = {};

	swfobject.embedSWF('flash/AIRInstallBadge.swf', 'debugger-badge', '215', '180', '9.0.115', 'flash/expressInstall.swf', flashvars, params, attributes);
})();
