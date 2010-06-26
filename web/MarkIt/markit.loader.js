(function() {

    function elem(id) {
        return g_document.getElementById(id);
    }

    function tags(name) {
        return g_document.getElementsByTagName(name);
    }

    function attr(node, name, value) {
        return value ? (node.setAttribute(name, value), node) : node.getAttribute(name);
    }

    function indexOf(s, s2) {
        return s.indexOf(s2);
    }

    function replace(s, pattern, s2) {
        return s.replace(pattern, s2);
    }

    function load_markit_js_by_script_tag() {
        script = g_document.createElement('script');
        attr(attr(attr(attr(attr(attr(attr(script,
                    'src', markit_url),
                    'j', jquery_url),
                    'u', jquery_ui_url),
                    'c', ckeditor_url),
                    'k', markit_key),
                    'charset', 'UTF-8'),
                    'id', id);
        script.ontimeout = script.onerror = function() {
            script.ontimeout = script.onerror = null;
            script.parentNode.removeChild(script);
            alert('Can\'t load ' + markit_url);
        }

        tags('body')[0].appendChild(script);
    }

    var g_document = document,      /* help YUI compressor */
        g_window = window,
        dialog = elem('markit-dialog'),
        id = 'markit-script',
        msg = 'Loading MarkIt dialog!',
        markit_key      = '##MARKIT_KEY##',
        markit_root     = '##MARKIT_ROOT##',
        markit_url      = markit_root + '##MARKIT_URL##',   /* for short script generated by index.html */
        jquery_url      = markit_root + '##JQUERY_URL##',
        jquery_ui_url   = markit_root + '##JQUERY_UI_URL##',
        ckeditor_url    = markit_root + '##CKEDITOR_URL##',
        file_protocol   = 'file:',
        markit_url_is_local = (indexOf(markit_url, file_protocol) == 0),
        script, scripts,
        xhr,
        i;

    if (dialog) {
        // markit.js must load jQuery and jQuery UI first, then create dialog
        jQuery(dialog).toggle();
        return;
    }


    if (elem(id)) {
        alert(msg);
        return;
    } else {
        scripts = tags('script');

        for (i = 0; i < scripts.length; ++i) {
            if (markit_url == attr(scripts[i], 'src')) {
                alert(msg);
                return;
            }
        }
    }

    if (! (indexOf(location.href, file_protocol) != 0 && markit_url_is_local)) {
        try {
            // prefer XMLHttpRequest to script tag for privacy, as other
            // scripts in this document won't peek into our private data,
            // especially `markit_key'.
            //
            // XMLHttpRequest in IE7 can't request local files, so we
            // we use the ActiveXObject when it is available.
            if (g_window.XMLHttpRequest && (! markit_url_is_local || ! g_window.ActiveXObject)) {
                xhr = new XMLHttpRequest();     // Firefox, Opera, Safari
            } else {
                xhr = new ActiveXObject('Microsoft.XMLHTTP');   // IE 5.5+
            }

            xhr.open('GET', markit_url, true);

            if (xhr.overrideMimeType) {
                // avoid Firefox treating it as text/xml to report a syntax error
                xhr.overrideMimeType('text/javascript; charset=UTF-8');
            }

            if (! markit_url_is_local) {
                xhr.setRequestHeader('User-Agent', 'Wget');
            }

            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    xhr.onreadystatechange = function() {};
                    i = xhr.status;

                    if (i == 200 || i == 0) {
                        script = xhr.responseText;
                        //alert('got script: ' + script);

                        // YUI compressor refuses to optimize scripts containing eval(),
                        // so we do a trick in Makefile, where EVAL is replaced with eval.
                        EVAL(replace(replace(replace(replace(script,
                                    /#j#/g, jquery_url),
                                    /#u#/g, jquery_ui_url),
                                    /#c#/g, ckeditor_url),
                                    /#k#/g, markit_key));
                    } else {
                        load_markit_js_by_script_tag();
                    }
                }
            }

            xhr.send(null);
            return;
        } catch (e) {
        }
    }

    load_markit_js_by_script_tag();

})()

