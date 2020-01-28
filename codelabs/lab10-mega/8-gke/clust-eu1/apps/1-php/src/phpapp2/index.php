<!DOCTYPE html>
<html>
<head>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon"/>
  <style type="text/css">
  <!--
  .bold {
    color:black;
    font-weight:bold;
    white-space:pre;
    padding-bottom: 3px;
  }
  .normal {
    color:blue;
    white-space:pre;
    padding-bottom: 3px;
  }
  .black {
    color: black;
    white-space:pre;
    padding-bottom: 3px;
  }
  -->
  </style>
</head>
<body>
<div>
  <img src="canary.png" />
</div>
<?php

  $headers = apache_request_headers();

  # Apache Server
  #======================
  echo "<h3>Apache Server</h3>";
  $host_name = php_uname("n");
  $server_addr = $_SERVER['SERVER_ADDR'];
  $server_port = $_SERVER['SERVER_PORT'];
  $server_proto = $_SERVER['SERVER_PROTOCOL'];
  $remote_addr = $_SERVER['REMOTE_ADDR'];
  $remote_port = $_SERVER['REMOTE_PORT'];

  $server = array(
    "PHP_UNAME:" => "<div class='bold'> $host_name </div>",
    "SERVER_ADDR:" => "<div class='normal'> $server_addr </div>",
    "REMOTE_ADDR:" => "<div class='normal'> $remote_addr </div>",
    "REMOTE_PORT:" => "<div class='normal'> $remote_port </div>",
    "SERVER_PORT:" => "<div class='normal'> $server_port </div>",
    "SERVER_PROTOCOL:" => "<div class='normal'> $server_proto </div>"
  );

  echo '<table>';
     foreach ($server as $parameter  =>  $value) {
       echo '<tr>' .
          '<td>' . $parameter .'</td>' .
          '<td>' . $value . '</td>' .
       '</tr>';
     }

  echo '</table>';
  echo '<br>';

    # Instance Metadata
  #======================
  echo "<h3>Instance Metadata</h3>";
  // get all instance metadata (from kubernetes node)
  $metadata = "http://metadata.google.internal/computeMetadata/v1";
  $header_array = array("Metadata-Flavor: Google");
  $fields = array(
    "SERVICE_ACCOUNT:" => "instance/service-accounts/",
    "INSTANCE_ZONE:" => "instance/zone",
    "INSTANCE_TAGS:" => "instance/tags",
    "CLUSTER_LOCATION:" => "instance/attributes/cluster-location",
    "CLUSTER_NAME:" => "instance/attributes/cluster-name"
  );

  echo '<table>';
     foreach ($fields as $parameter  =>  $value) {
       $ch = curl_init();
       $options = array(CURLOPT_URL => "$metadata/$value");
       curl_setopt($ch, CURLOPT_HTTPHEADER, $header_array);
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
       curl_setopt_array($ch, $options);
       $curl_res = curl_exec($ch);

       echo '<tr>' .
          '<td>' . $parameter .'</td>' .
          '<td>' . "<div class='normal'> $curl_res </div>" . '</td>' .
       '</tr>';

       curl_close($ch);
     }

  echo '</table>';
  echo '<br>';

  # ENV
  #======================
  echo "<h3>ENV</h3>";
  $host_ip = $_ENV['HOST_IP'];
  $pod_ip = $_ENV['POD_IP'];
  $node_name = $_ENV['NODE_NAME'];
  $pod_name = file_get_contents('/etc/podinfo/name', true);
  $namespace = file_get_contents('/etc/podinfo/namespace', true);
  $service_account_name = $_ENV['SERVICE_ACCOUNT_NAME'];
  $uid = file_get_contents('/etc/podinfo/uid', true);
  $labels = file_get_contents('/etc/podinfo/labels', true);
  $annotations = file_get_contents('/etc/podinfo/annotations', true);

  $pod = array(
    "HOST_IP:" => "<div class='normal'> $host_ip </div>",
    "POD_IP:" => "<div class='normal'> $pod_ip </div>",
    "NODE_NAME:" => "<div class='normal'> $node_name </div>",
    "POD_NAME:" => "<div class='normal'> $pod_name </div>",
    "NAMESPACE:" => "<div class='normal'> $namespace </div>",
    "SERVICE_ACCOUNT:" => "<div class='normal'> $service_account_name </div>",
    "UID:" => "<div class='normal'> $uid </div>",
    "LABELS:" => "<div class='normal'> $labels </div>",
    "ANNOTATIONS:" => "<div class='normal'> $annotations </div>"
  );

  echo '<table>';

     foreach ($pod as $parameter  =>  $value) {
       echo '<tr>' .
          '<td>' . $parameter .'</td>' .
          '<td>' . $value . '</td>' .
       '</tr>';
     }

  echo '</table>';
  echo '<br>';

  # Headers
  #======================
  echo "<h3>Headers</h3>";
  echo '<table>';

     foreach ($headers as $header => $value) {
       echo '<tr>' .
          '<td>' . $header .':</td>' .
          '<td>' . $value . '</td>' .
       '</tr>';
     }

  echo '</table>';
  echo '<br>';

  # kube-env parameters
  #======================
  echo "<h3>kube-env</h3>";
  // get all kube-env parameters
  $metadata = "http://metadata.google.internal/computeMetadata/v1";
  $header_array = array("Metadata-Flavor: Google");
  $field = "instance/attributes/kube-env";
  $ch = curl_init();
  $options = array(CURLOPT_URL => "$metadata/$field");
  curl_setopt($ch, CURLOPT_HTTPHEADER, $header_array);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt_array($ch, $options);
  $curl_res = curl_exec($ch);
  curl_close($ch);
  echo "<div class='black'> $curl_res </div>";

?>
</body>
</html>
