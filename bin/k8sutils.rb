require 'digest/sha1'
require 'rest-client'

class K8sUtils
  STABLE_RELEASE_URL="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
  HEAD_RELEASE_URL="https://storage.googleapis.com/kubernetes-release-dev/ci/k8s-master.txt"
  HEAD_RELEASE_FAST_URL="https://storage.googleapis.com/kubernetes-release-dev/ci/latest.txt"

  def self.kubernetes_release(release_type)
    release_url = case release_type
                  when "stable"
                    "#{STABLE_RELEASE_URL}"
                  when "stable/amd64"
                    "#{STABLE_RELEASE_URL}"
                  when "stable/arm64"
                    "#{STABLE_RELEASE_URL}"
                  when "head/amd64"
                    "#{HEAD_RELEASE_URL}"
                  when "head/arm64"
                    "#{HEAD_RELEASE_URL}"
                  else
                    puts "Release type #{release_type} unknown!"
                    exit 1
                  end

    response = Faraday.get release_url
    if response.body.nil?
      @logger.error "Failed to download release for #{release_type}"
      return
    end

    kubernetes_release = "#{response.body}"
  end

  def self.k8s_sha(download_url)
    response = Faraday.get "#{download_url}.sha256"
    unless response.body.split[0].size == 64
      response = Faraday.get download_url
      raw = RestClient::Request.execute(
        method: :get,
        url: download_url,
        log: Logger.new(STDOUT),
        raw_response: true)
      Digest::SHA256.file(raw.file.path).hexdigest
    end
    response.body.split[0]
  end

  def self.k8s_publish(release, platforms, registry)
    `./import_push_with_manifest.sh "#{release}" "#{platforms}" "#{registry}"`
  end
end
