job "certchecker" {
    datacenters = [ "dc1" ] 
    type = "service"
    priority = 50
    update {
        max_parallel      = 1
        health_check      = "checks"
        min_healthy_time  = "30s"
        healthy_deadline  = "5m"
        progress_deadline = "10m"
        auto_revert       = true
        stagger           = "30s"
    }
    group "exporter" {
        count = 1
        network {
            port "http" {}   
        }
        reschedule {
            delay          = "5s"
            delay_function = "fibonacci"
            max_delay      = "120s"
            unlimited      = true
        }
        task "exporter-domain" {
            service {
                tags = [ "gastro.io" ]
                name = "blackbox-exporter"
                port = "http"
                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "5s"
                }
            }
            resources {
                cpu = 100
                memory = 256
            }
            # Blackbox Configuration - Application parameters
            template {
                data = <<__EOT__
modules:
  http_2xx:
    prober: http
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  icmp:
    prober: icmp
    __EOT__
               destination = "local/config.yml"
  }

            driver = "docker"
            kill_timeout = "60s"
            kill_signal = "SIGUSR2"
            config {
		        image = "prom/blackbox-exporter:v0.22.0"
                ports = ["http"]
                args    = ["--config.file", "local/config.yml", "--web.listen-address", ":${NOMAD_PORT_http}" ]
            }
            logs {
                max_files     = 1
                max_file_size = 100
            }
        }
    }    
}

