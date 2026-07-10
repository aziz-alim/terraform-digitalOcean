terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Token için bir değişken tanımlıyoruz (sensitive = true diyerek loglarda gizlenmesini sağlıyoruz)
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

# DigitalOcean Bağlantı Ayarı
provider "digitalocean" {
  token = var.do_token
}

# Yeni anahtar oluşturmak yerine DigitalOcean'daki mevcut anahtarı oku
data "digitalocean_ssh_key" "devops_key" {
  name = "Mac-DevOps-Key"
}

# Oluşturulacak Droplet (Sanal Sunucu) Özellikleri
resource "digitalocean_droplet" "web_server" {
  image    = "ubuntu-24-04-x64"       # İşletim sistemi şablonu
  name     = "terraform-pomodoro"     # Sunucu adı
  region   = "fra1"                   # Frankfurt bölgesi
  size     = "s-1vcpu-1gb"            # 1 vCPU, 1 GB RAM (En ucuz paket)
  ssh_keys = [data.digitalocean_ssh_key.devops_key.id]
}

# Sunucu açıldıktan sonra IP adresini ekrana yazdırma
output "server_ip" {
  value       = digitalocean_droplet.web_server.ipv4_address
  description = "Yeni açılan sunucunun halka açık IP adresi"
}
