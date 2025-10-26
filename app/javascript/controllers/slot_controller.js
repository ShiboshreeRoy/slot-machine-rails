import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reel", "bet", "message", "history", "value"]
  static values = { url: String }

  connect() {
    this.spinning = false
  }

  async spin() {
    if (this.spinning) return
    this.spinning = true
    const bet = this.betTarget.value || 1

    // start local animation: cycle random images quickly
    this.startFastSpin()

    try {
      const resp = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ bet: bet })
      })

      const data = await resp.json()
      if (!data.success) throw new Error(data.error || 'Spin failed')

      // stop animation and show result
      await this.showResult(data.spin.reels)
      this.updateBalance(data.balance)
      this.prependHistory(data.spin.reels, data.spin.win)
      this.showMessage(`You won ${data.spin.win}`)

    } catch (err) {
      this.showMessage(err.message)
    } finally {
      this.spinning = false
      this.stopFastSpin()
    }
  }

  startFastSpin() {
    // change each reel image every 80ms
    this.intervals = this.reelTargets.map((el) => {
      return setInterval(() => {
        el.querySelector('img').src = this.randomImage()
      }, 80)
    })
  }

  stopFastSpin() {
    if (!this.intervals) return
    this.intervals.forEach(clearInterval)
    this.intervals = null
  }

  randomImage() {
    const symbols = ['cherry','lemon','seven','bar','bell']
    return new URL(`/assets/reels/${symbols[Math.floor(Math.random()*symbols.length)]}.png`, window.location.origin).href
  }

  async showResult(reels) {
    // show each reel with a delay to emulate mechanical stop
    for (let i = 0; i < reels.length; i++) {
      const el = this.reelTargets[i]
      const img = el.querySelector('img')
      // small delay
      await new Promise(r => setTimeout(r, 400 + i*300))
      img.src = new URL(`/assets/reels/${reels[i]}.png`, window.location.origin).href
    }
  }

  updateBalance(balance) {
    if (this.hasValueTarget) {
      this.valueTarget.querySelector('span').textContent = balance
    }
  }

  prependHistory(reels, win) {
    if (!this.hasHistoryTarget) return
    const li = document.createElement('li')
    li.textContent = `${new Date().toLocaleTimeString()} — ${reels.join(', ')} — Win: ${win}`
    this.historyTarget.prepend(li)
  }

  showMessage(text) {
    if (this.hasMessageTarget) this.messageTarget.textContent = text
  }
}