# browse
#-------------------------------------------

# asia

resource "google_compute_instance_group_manager" "browse_asia" {
  name               = "browse-asia"
  base_instance_name = "browse-asia"
  instance_template  = google_compute_instance_template.web_asia.self_link
  zone               = "${var.default.asia.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "browse_asia" {
  name   = "browse-asia"
  zone   = "${var.default.asia.region}-b"
  target = google_compute_instance_group_manager.browse_asia.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "browse_eu" {
  name               = "browse-eu"
  base_instance_name = "browse-eu"
  instance_template  = google_compute_instance_template.web_eu.self_link
  zone               = "${var.default.eu.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "browse_eu" {
  name   = "browse-eu"
  zone   = "${var.default.eu.region}-b"
  target = google_compute_instance_group_manager.browse_eu.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# us

resource "google_compute_instance_group_manager" "browse_us" {
  name               = "browse-us"
  base_instance_name = "browse-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "browse_us" {
  name   = "browse-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.browse_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# cart
#-------------------------------------------

# asia

resource "google_compute_instance_group_manager" "cart_asia" {
  name               = "cart-asia"
  base_instance_name = "cart-asia"
  instance_template  = google_compute_instance_template.web_asia.self_link
  zone               = "${var.default.asia.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "cart_asia" {
  name   = "cart-asia"
  zone   = "${var.default.asia.region}-b"
  target = google_compute_instance_group_manager.cart_asia.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "cart_eu" {
  name               = "cart-eu"
  base_instance_name = "cart-eu"
  instance_template  = google_compute_instance_template.web_eu.self_link
  zone               = "${var.default.eu.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "cart_eu" {
  name   = "cart-eu"
  zone   = "${var.default.eu.region}-b"
  target = google_compute_instance_group_manager.cart_eu.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# us

resource "google_compute_instance_group_manager" "cart_us" {
  name               = "cart-us"
  base_instance_name = "cart-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "cart_us" {
  name   = "cart-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.cart_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# checkout
#-------------------------------------------

# asia

resource "google_compute_instance_group_manager" "checkout_asia" {
  name               = "checkout-asia"
  base_instance_name = "checkout-asia"
  instance_template  = google_compute_instance_template.web_asia.self_link
  zone               = "${var.default.asia.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "checkout_asia" {
  name   = "checkout-asia"
  zone   = "${var.default.asia.region}-b"
  target = google_compute_instance_group_manager.checkout_asia.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "checkout_eu" {
  name               = "checkout-eu"
  base_instance_name = "checkout-eu"
  instance_template  = google_compute_instance_template.web_eu.self_link
  zone               = "${var.default.eu.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "checkout_eu" {
  name   = "checkout-eu"
  zone   = "${var.default.eu.region}-b"
  target = google_compute_instance_group_manager.checkout_eu.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 3

    cpu_utilization {
      target = 0.6
    }
  }
}

# us

resource "google_compute_instance_group_manager" "checkout_us" {
  name               = "checkout-us"
  base_instance_name = "checkout-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "checkout_us" {
  name   = "checkout-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.checkout_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# feeds
#-------------------------------------------

# asia

resource "google_compute_instance_group_manager" "feeds_asia" {
  name               = "feeds-asia"
  base_instance_name = "feeds-asia"
  instance_template  = google_compute_instance_template.web_asia.self_link
  zone               = "${var.default.asia.region}-b"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "feeds_asia" {
  name   = "feeds-asia"
  zone   = "${var.default.asia.region}-b"
  target = google_compute_instance_group_manager.feeds_asia.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# eu

resource "google_compute_region_instance_group_manager" "feeds_eu_regional" {
  name               = "feeds-eu-regional"
  base_instance_name = "feeds-eu-regional"
  instance_template  = google_compute_instance_template.web_eu.self_link
  region             = var.default.eu.region
  target_size        = "5"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "feeds_eu_regional" {
  name   = "feeds-eu-regional"
  region = var.default.eu.region
  target = google_compute_region_instance_group_manager.feeds_eu_regional.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 5

    cpu_utilization {
      target = 0.6
    }
  }
}

# us

resource "google_compute_instance_group_manager" "feeds_us" {
  name               = "feeds-us"
  base_instance_name = "feeds-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "feeds_us" {
  name   = "feeds-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.feeds_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# db
#-------------------------------------------

# asia

resource "google_compute_instance_group" "db_asia" {
  name      = "db-asia"
  zone      = "${var.default.asia.region}-b"
  instances = [google_compute_instance.db_asia.self_link]
}

# eu

resource "google_compute_instance_group" "db_eu" {
  name      = "db-eu"
  zone      = "${var.default.eu.region}-b"
  instances = [google_compute_instance.db_eu.self_link]
}

# us

resource "google_compute_instance_group" "db_us" {
  name      = "db-us"
  zone      = "${var.default.us.region}-c"
  instances = [google_compute_instance.db_us.self_link]
}

# payment processing
#-------------------------------------------

# us

resource "google_compute_instance_group_manager" "payment_processing_us" {
  name               = "payment-processing-us"
  base_instance_name = "payment-processing-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "payment_processing_us" {
  name   = "payment-processing-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.payment_processing_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}

# vpc peering
#-------------------------------------------

# us

resource "google_compute_instance_group_manager" "vpc_peering_us" {
  name               = "vpc-peering-us"
  base_instance_name = "vpc-peering-us"
  instance_template  = google_compute_instance_template.web_us.self_link
  zone               = "${var.default.us.region}-c"
  target_size        = "1"

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "vpc_peering_us" {
  name   = "vpc-peering-us"
  zone   = "${var.default.us.region}-c"
  target = google_compute_instance_group_manager.vpc_peering_us.self_link

  autoscaling_policy {
    max_replicas = 10
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }
  }
}
