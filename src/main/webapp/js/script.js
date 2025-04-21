// 모바일 메뉴 토글 기능
document.addEventListener("DOMContentLoaded", () => {
  const menuToggle = document.querySelector(".menu-toggle")
  const navMenu = document.querySelector("nav ul")

  if (menuToggle) {
    menuToggle.addEventListener("click", () => {
      navMenu.classList.toggle("show")
    })
  }

  // 알림 읽음 표시 기능
  const notificationLinks = document.querySelectorAll(".notification-item a")
  notificationLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      const notificationId = this.closest(".notification-item").dataset.id
      if (notificationId) {
        fetch("mark_notification_read.jsp?id=" + notificationId)
          .then((response) => {
            this.closest(".notification-item").classList.add("read")
          })
          .catch((error) => console.error("Error:", error))
      }
    })
  })

  // 파일 업로드 시 파일명 표시
  const fileInputs = document.querySelectorAll('input[type="file"]')
  fileInputs.forEach((input) => {
    input.addEventListener("change", function () {
      const fileName = this.value.split("\\").pop()
      const fileLabel = this.nextElementSibling
      if (fileLabel && fileLabel.classList.contains("file-label")) {
        fileLabel.textContent = fileName || "파일 선택"
      }
    })
  })
})

// 알림 실시간 업데이트 (5분마다)
function updateNotifications() {
  fetch("get_notification_count.jsp")
    .then((response) => response.json())
    .then((data) => {
      const badge = document.querySelector(".notification-badge")
      if (badge) {
        if (data.count > 0) {
          badge.textContent = data.count
          badge.style.display = "inline-block"
        } else {
          badge.style.display = "none"
        }
      }
    })
    .catch((error) => console.error("Error:", error))
}

// 페이지 로드 시 알림 업데이트 시작
if (document.querySelector(".notification-badge")) {
  updateNotifications()
  setInterval(updateNotifications, 300000) // 5분마다 업데이트
}
