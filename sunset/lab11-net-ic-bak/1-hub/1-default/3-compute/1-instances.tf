
# browse
#-------------------------------------------

# asia

locals {
  browse_asia_init = templatefile("scripts/browse.sh.tpl", {
    TARGET     = var.hub.default.asia.db_ip
    apache_dir = "browse"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "browse_asia" {
  name                      = "browse-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.browse_asia_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.browse_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  browse_eu_init = templatefile("scripts/browse.sh.tpl", {
    TARGET     = var.hub.default.eu.db_ip
    apache_dir = "browse"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "browse_eu" {
  name                      = "browse-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.browse_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.browse_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  browse_us_init = templatefile("scripts/browse.sh.tpl", {
    TARGET     = var.hub.default.us.db_ip
    apache_dir = "browse"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "browse_us" {
  name                      = "browse-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.browse_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.browse_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cart
#-------------------------------------------

# asia

locals {
  cart_asia_init = templatefile("scripts/cart.sh.tpl", {
    TARGET     = var.hub.default.asia.db_ip
    apache_dir = "cart"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "cart_asia" {
  name                      = "cart-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.cart_asia_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.cart_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  cart_eu_init = templatefile("scripts/cart.sh.tpl", {
    TARGET     = var.hub.default.eu.db_ip
    apache_dir = "cart"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "cart_eu" {
  name                      = "cart-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.cart_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.cart_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  cart_us_init = templatefile("scripts/cart.sh.tpl", {
    TARGET     = var.hub.default.us.db_ip
    apache_dir = "cart"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "cart_us" {
  name                      = "cart-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.cart_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.cart_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# checkout
#-------------------------------------------

# asia

locals {
  checkout_asia_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET     = var.hub.default.asia.db_ip
    apache_dir = "checkout"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "checkout_asia" {
  name                      = "checkout-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.checkout_asia_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.checkout_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  checkout_eu_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET     = var.hub.default.eu.db_ip
    apache_dir = "checkout"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "checkout_eu1" {
  name                      = "checkout-eu1"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.checkout_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.checkout_ip1
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "checkout_eu2" {
  name                      = "checkout-eu2"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.checkout_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.checkout_ip2
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "checkout_eu3" {
  name                      = "checkout-eu3"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.checkout_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.checkout_ip3
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  checkout_us_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET     = var.hub.default.us.db_ip
    apache_dir = "checkout"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "checkout_us" {
  name                      = "checkout-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.checkout_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.checkout_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}


# feeds
#-------------------------------------------

# asia

locals {
  feeds_asia_init = templatefile("scripts/feeds.sh.tpl", {
    TARGET     = var.hub.default.asia.db_ip
    apache_dir = "feeds"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "feeds_asia" {
  name                      = "feeds-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.feeds_asia_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.feeds_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  feeds_eu_init = templatefile("scripts/feeds.sh.tpl", {
    TARGET     = var.hub.default.eu.db_ip
    apache_dir = "feeds"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "feeds_eu1" {
  name                      = "feeds-eu1"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.feeds_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.feeds_ip1
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "feeds_eu2" {
  name                      = "feeds-eu2"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.feeds_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.feeds_ip2
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "feeds_eu3" {
  name                      = "feeds-eu3"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.feeds_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.feeds_ip3
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  feeds_us_init = templatefile("scripts/feeds.sh.tpl", {
    TARGET     = var.hub.default.us.db_ip
    apache_dir = "feeds"
    n          = 5
    c          = 2
  })
}

resource "google_compute_instance" "feeds_us" {
  name                      = "feeds-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.feeds_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.feeds_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# db
#-------------------------------------------

# asia

locals {
  db_asia_init = templatefile("scripts/db.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    n      = 5
    c      = 2
  })
}

resource "google_compute_instance" "db_asia" {
  name                      = "db-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.db_asia_init
  allow_stopping_for_update = true
  tags                      = ["external-db"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  db_eu_init = templatefile("scripts/db.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    n      = 5
    c      = 2
  })
}

resource "google_compute_instance" "db_eu" {
  name                      = "db-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.db_eu_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  db_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance" "db_us" {
  name                      = "db-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-b"
  metadata_startup_script   = local.db_us_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# batch jobs
#-------------------------------------------

# eu

locals {
  batch_jobs_eu_init = templatefile("scripts/batch.sh.tpl", {
    TARGET = var.hub.default.asia.db_ip
    n      = 2000
    c      = 100
  })
}

resource "google_compute_instance" "batch_job_eu" {
  name                      = "batch-job-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-c"
  metadata_startup_script   = local.batch_jobs_eu_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.batch_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  batch_jobs_us_init = templatefile("scripts/batch-us.sh.tpl", {
    TARGET = var.hub.default.us.ilb_vip
    n      = 6
    c      = 5
  })
}

resource "google_compute_instance" "batch_job_us" {
  name                      = "batch-job-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.batch_jobs_us_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.batch_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# smtp server
#-------------------------------------------

# us

locals {
  smtp_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance" "smtp_us" {
  name                      = "smtp-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.smtp_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.smtp_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# payment processing
#-------------------------------------------

# us

locals {
  processing_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance" "payment_us" {
  name                      = "payment-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  metadata_startup_script   = local.processing_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.payment_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
