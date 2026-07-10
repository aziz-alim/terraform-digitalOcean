# Automated Cloud Infrastructure with Terraform & Ansible

Bu proje, bir bulut sunucusunun (DigitalOcean Droplet) altyapısının tamamen kodla ayağa kaldırılmasını (Provisioning) ve ardından bu sunucunun otomatik olarak yapılandırılarak (Configuration Management) bir web uygulamasının canlıya alınmasını sağlayan uçtan uca bir DevOps hattıdır.

Projede bulut kaynakları **Terraform** ile yönetilirken, sunucu içi bağımlılıklar ve deployment süreçleri **Ansible** ile orkestre edilmiştir.

---

## Kullanılan Teknolojiler ve Rol Dağılımı

- **Terraform (Altyapı Sağlayıcı - IaC):** DigitalOcean üzerinde API entegrasyonu ile otomatik Droplet (Ubuntu 24.04) oluşturur, SSH anahtarlarını tanımlar ve sunucuyu ağa bağlar.
- **Ansible (Konfigürasyon Yönetimi):** Terraform'un oluşturduğu boş sunucuya bağlanarak Node.js v22 (LTS) ortamını kurar, Nginx web sunucusunu yapılandırır ve projenin canlı sürümünü derleyip yayına alır.
- **Uygulama Katmanı:** React + Vite (Pomodoro Timer) statik web uygulaması.

---

## Proje Klasör Yapısı

Süreçlerin net ayrımı (Separation of Concerns) adına Terraform ve Ansible yapılandırmaları bağımsız modüller halinde organize edilmiştir:

```text
.
├── terraform-do/               # Altyapı Tanım Klasörü
│   ├── main.tf                 # DigitalOcean kaynak tanımları ve provider ayarları
│   └── terraform.tfstate       # Altyapının mevcut durumunu tutan state dosyası
│
└── ansible-infra/              # Sunucu Yapılandırma Klasörü
    ├── inventory.ini           # Terraform'dan alınan dinamik sunucu IP adresi
    ├── setup.yml               # Ana playbook orkestratörü
    └── roles/                  # Modüler Ansible rolleri (base, nginx, app, ssh)
```

---

## Kurulum ve Dağıtım Adımları

### 1. Adım: Güvenlik ve Kimlik Doğrulama
Güvenlik standartları (Secret Management) gereği DigitalOcean API token bilgisi koda (hardcoded) yazılmamalıdır. İşleme başlamadan önce token bilgisini sisteminize ortam değişkeni (environment variable) olarak tanımlayın:

```bash
export TF_VAR_do_token="BURAYA_DIGITALOCEAN_API_TOKEN_GELECEK"
```

### 2. Adım: Bulut Altyapısının Oluşturulması (Terraform)
`terraform-do` klasörüne geçiş yapın ve altyapıyı ayağa kaldırmak için şu komutları sırayla çalıştırın:

```bash
# Eklentileri indir ve projeyi başlat
terraform init

# Değişiklikleri doğrula ve simüle et
terraform plan

# Altyapıyı bulutta fiziki olarak ayağa kaldır
terraform apply
```
Kurulum tamamlandığında Terraform terminal ekranına sunucunun halka açık yeni IP adresini (`server_ip`) yazdıracaktır.

### 3. Adım: Sunucu Yapılandırması ve Canlıya Alma (Ansible)
Terraform'un ürettiği IP adresini `ansible-infra/inventory.ini` dosyasına ekleyin. Eğer aynı IP adresiyle daha önce başka bir sunucuya bağlandıysanız, yerel makinenizdeki eski SSH kimlik kaydını temizleyin:

```bash
ssh-keygen -R <YENI_SUNUCU_IP>
```

Ardından, `ansible-infra` klasörüne geçerek playbook'u sadece ilgili tag'ler ile tetikleyin:

```bash
ansible-playbook setup.yml -i inventory.ini --tags "nginx,app"
```

---

## DevOps Best Practices ve Kazanımlar

- **Secret Management (Gizli Veri Yönetimi):** API anahtarları veya hassas bilgiler kod içinde tutulmaz; ortam değişkenleri kullanılarak güvenli bir şekilde aktarılır ve olası sızıntıların önüne geçilir.
- **Idempotency:** Yazılan kodlar tekrar tekrar çalıştırılabilir. Sunucu zaten istenen durumdaysa hiçbir kaynağa zarar verilmez veya gereksiz paket kurulmaz.
- **Modüler Yapı:** Sunucuyu açan katman (Terraform) ile sunucuyu yöneten katman (Ansible) tamamen birbirinden ayrılmıştır; bulut sağlayıcısı değiştirilse bile Ansible rolleri aynen korunabilir.
- **Güvenli Erişim:** Sunucuya şifre ile girişler kapatılmış, erişim yalnızca belirli bir SSH Private Key mimarisi ve MD5 parmak izi (fingerprint) doğrulaması üzerinden yapılandırılmıştır.

---

## Geliştirici

- **Aziz Mevlana Alim** - [GitHub](https://github.com/aziz-mevlana) - [Roadmap](https://github.com/aziz-mevlana](https://roadmap.sh/projects/iac-digitalocean))

