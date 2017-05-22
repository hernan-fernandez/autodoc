<?php

require("lib/library.inc.php");
$mysqli=dbconnect();

$USERNAME = "autodoc"; // Wordpress admin or publisher username
$PASSWORD = "";        // Wordpress admin or publisher password
$WEBSERVER_IP = "127.0.0.1";

$directory = '/path/to/output/files/directory'; // directory without trailing slash
$filelist  = scandir($directory);

/* it will scan the generated files and then upload each one to wordpress */
foreach ($filelist as $file) {

        if (($file == ".") OR ($file == "..")) { continue; }

        $ip=$file;
        $pathfile = "$directory/$file";
        $gestor = fopen($pathfile, "r");
        if (filesize($pathfile) == 0) { continue; }
        $body = fread($gestor, filesize($pathfile));
        fclose($gestor);


        if ($post_id = get_post_id($ip)) {
                echo "editing post ".$post_id."\n";
                edit_post($ip,$post_id,$body);
        } else {
                $post_id=create_post($ip,$body);
                add_relation_post_ip($ip,$post_id);
        }
}




function create_post($ip, $body ) {
global $USERNAME, $PASSWORD;

    $content = array(
        'post_type' => 'post',
        'post_status' => 'publish',
        'post_title' => $ip,
        'post_content' => $body,
        'comment_status' => 'closed',
    );

    $opt_enc= array('encoding'=>'ISO8859-2','escaping'=>'markup');
    $params = array( 0, $USERNAME, $PASSWORD, $content );
    $request = xmlrpc_encode_request( 'wp.newPost', $params, $opt_enc);


     /*Making the request to wordpress XMLRPC of your blog*/
    if(!$xmlresponse = get_response("http://$WEBSERVER_IP/xmlrpc.php", $request)) {
        //echo "ERROR";
    	return false;
    } else {
    	$xml=simplexml_load_string($xmlresponse) or die("Error: Cannot create object");
        return $xml->params->param->value->string; // return ID of the new post.
    }
}


function edit_post($ip,$post_id,$body) {
global $USERNAME, $PASSWORD;

        $content = array(
        'post_type' => 'post',
        'post_status' => 'publish',
        'post_title' => $ip,
        'post_content' => $body,
        'post_modified' => date("YYYYMMDDThh:mm:ss"),
        'comment_status' => 'closed',
    );

        $opt_enc= array('encoding'=>'ISO8859-2','escaping'=>'markup');
        $params = array( 0, $USERNAME, $PASSWORD, $post_id, $content );
        $request = xmlrpc_encode_request( 'wp.editPost', $params,$opt_enc);


        /*Making the request to wordpress XMLRPC of your blog*/
        $xmlresponse = get_response("http://$WEBSERVER_IP/xmlrpc.php", $request);
        $xml=simplexml_load_string($xmlresponse) or die("Error: Cannot create object");

        $response = xmlrpc_decode($xmlresponse);

}




?>

