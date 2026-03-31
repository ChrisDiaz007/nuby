import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form", "startBtn", "stopBtn", "preview"]

  start() {
    this.startBtnTarget.classList.add("hidden")
    this.stopBtnTarget.classList.remove("hidden")
    this.previewTarget.classList.remove("hidden")

    Quagga.init({
      inputStream: {
        type: "LiveStream",
        target: this.previewTarget,
        constraints: { facingMode: "environment" }
      },
      decoder: {
        readers: ["ean_reader", "ean_8_reader", "upc_reader", "upc_e_reader"]
      }
    }, (err) => {
      if (err) { console.error(err); return }
      Quagga.start()
    })

    Quagga.onDetected((result) => {
      const code = result.codeResult.code
      this.inputTarget.value = code
      this.stop()
      this.formTarget.submit()
    })
  }

  stop() {
    Quagga.stop()
    this.previewTarget.classList.add("hidden")
    this.startBtnTarget.classList.remove("hidden")
    this.stopBtnTarget.classList.add("hidden")
  }
}
