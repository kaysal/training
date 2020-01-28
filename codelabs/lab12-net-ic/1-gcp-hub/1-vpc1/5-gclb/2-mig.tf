
# browse
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "browse_asia" {
  name               = "browse-asia"
  base_instance_name = "browse-asia"
  zone               = "${var.hub.vpc1.asia.region}-b"

  version {
    instance_template = local.templates.browse_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "browse_asia" {
  name   = "browse-asia"
  zone   = "${var.hub.vpc1.asia.region}-b"
  target = google_compute_instance_group_manager.browse_asia.self_link

  autoscaling_policy {
    min_replicas    = 3
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "browse_eu" {
  name               = "browse-eu"
  base_instance_name = "browse-eu"
  zone               = "${var.hub.vpc1.eu.region}-b"

  version {
    instance_template = local.templates.browse_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "browse_eu" {
  name   = "browse-eu"
  zone   = "${var.hub.vpc1.eu.region}-b"
  target = google_compute_instance_group_manager.browse_eu.self_link

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us
resource "google_compute_instance_group_manager" "browse_us" {
  name               = "browse-us"
  base_instance_name = "browse-us"
  zone               = "${var.hub.vpc1.us.region}-c"

  version {
    instance_template = local.templates.browse_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "browse_us" {
  name   = "browse-us"
  zone   = "${var.hub.vpc1.us.region}-c"
  target = google_compute_instance_group_manager.browse_us.self_link

  autoscaling_policy {
    min_replicas    = 4
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}


# cart
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "cart_asia" {
  name               = "cart-asia"
  base_instance_name = "cart-asia"
  zone               = "${var.hub.vpc1.asia.region}-b"

  version {
    instance_template = local.templates.cart_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "cart_asia" {
  name   = "cart-asia"
  zone   = "${var.hub.vpc1.asia.region}-b"
  target = google_compute_instance_group_manager.cart_asia.self_link

  autoscaling_policy {
    min_replicas    = 3
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "cart_eu" {
  name               = "cart-eu"
  base_instance_name = "cart-eu"
  zone               = "${var.hub.vpc1.eu.region}-b"

  version {
    instance_template = local.templates.cart_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "cart_eu" {
  name   = "cart-eu"
  zone   = "${var.hub.vpc1.eu.region}-b"
  target = google_compute_instance_group_manager.cart_eu.self_link

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us
resource "google_compute_instance_group_manager" "cart_us" {
  name               = "cart-us"
  base_instance_name = "cart-us"
  zone               = "${var.hub.vpc1.us.region}-c"

  version {
    instance_template = local.templates.cart_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "cart_us" {
  name   = "cart-us"
  zone   = "${var.hub.vpc1.us.region}-c"
  target = google_compute_instance_group_manager.cart_us.self_link

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}


# checkout
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "checkout_asia" {
  name               = "checkout-asia"
  base_instance_name = "checkout-asia"
  zone               = "${var.hub.vpc1.asia.region}-b"

  version {
    instance_template = local.templates.checkout_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "checkout_asia" {
  name   = "checkout-asia"
  zone   = "${var.hub.vpc1.asia.region}-b"
  target = google_compute_instance_group_manager.checkout_asia.self_link

  autoscaling_policy {
    min_replicas    = 3
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "checkout_eu" {
  name               = "checkout-eu"
  base_instance_name = "checkout-eu"
  zone               = "${var.hub.vpc1.eu.region}-b"

  version {
    instance_template = local.templates.checkout_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "checkout_eu" {
  name   = "checkout-eu"
  zone   = "${var.hub.vpc1.eu.region}-b"
  target = google_compute_instance_group_manager.checkout_eu.self_link

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us

resource "google_compute_instance_group_manager" "checkout_us" {
  name               = "checkout-us"
  base_instance_name = "checkout-us"
  zone               = "${var.hub.vpc1.us.region}-c"

  version {
    instance_template = local.templates.checkout_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 20
  }
}

resource "google_compute_autoscaler" "checkout_us" {
  name   = "checkout-us"
  zone   = "${var.hub.vpc1.us.region}-c"
  target = google_compute_instance_group_manager.checkout_us.self_link

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}
