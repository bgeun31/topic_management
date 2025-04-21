// DOM 로드 이벤트
document.addEventListener("DOMContentLoaded", () => {
  initMobileMenu();
  initNotifications();
  initFileUploadLabels();
  initTableResponsive();
  initFormValidation();
  addScrollEffects();
});

// 모바일 메뉴 토글 기능
function initMobileMenu() {
  const menuToggle = document.querySelector(".menu-toggle");
  const navMenu = document.querySelector("nav ul");

  if (menuToggle) {
    menuToggle.addEventListener("click", () => {
      navMenu.classList.toggle("show");
      menuToggle.setAttribute(
        "aria-expanded", 
        navMenu.classList.contains("show") ? "true" : "false"
      );
    });

    // 메뉴 아이템 클릭 시 자동으로 메뉴 닫기
    const menuItems = document.querySelectorAll("nav ul li a");
    menuItems.forEach(item => {
      item.addEventListener("click", () => {
        if (window.innerWidth <= 768) {
          navMenu.classList.remove("show");
          menuToggle.setAttribute("aria-expanded", "false");
        }
      });
    });

    // 화면 크기 변경 시 모바일 메뉴 처리
    window.addEventListener("resize", () => {
      if (window.innerWidth > 768) {
        navMenu.classList.remove("show");
        menuToggle.setAttribute("aria-expanded", "false");
      }
    });
  }
}

// 알림 읽음 표시 기능
function initNotifications() {
  const notificationLinks = document.querySelectorAll(".notification-item a");
  notificationLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      const notificationId = this.closest(".notification-item").dataset.id;
      if (notificationId) {
        fetch(`mark_notification_read.jsp?id=${notificationId}`)
          .then((response) => {
            if (response.ok) {
              this.closest(".notification-item").classList.add("read");
            }
          })
          .catch((error) => console.error("Error:", error));
      }
    });
  });
}

// 파일 업로드 시 파일명 표시
function initFileUploadLabels() {
  const fileInputs = document.querySelectorAll('input[type="file"]');
  fileInputs.forEach((input) => {
    input.addEventListener("change", function () {
      const fileName = this.value.split("\\").pop();
      const fileLabel = this.nextElementSibling;
      if (fileLabel && fileLabel.classList.contains("file-label")) {
        fileLabel.textContent = fileName || "파일 선택";
      } else {
        // 라벨이 없는 경우, 부모 요소에 파일 이름 표시
        const fileInfo = document.createElement("p");
        fileInfo.classList.add("file-info");
        fileInfo.textContent = `선택된 파일: ${fileName}`;
        
        // 기존 파일 정보가 있으면 교체
        const existingInfo = this.parentElement.querySelector(".file-info");
        if (existingInfo) {
          existingInfo.textContent = `선택된 파일: ${fileName}`;
        } else {
          this.insertAdjacentElement("afterend", fileInfo);
        }
      }
    });
  });
}

// 반응형 테이블을 위한 데이터 라벨 추가
function initTableResponsive() {
  const tables = document.querySelectorAll(".data-table");
  tables.forEach(table => {
    const headerCells = table.querySelectorAll("thead th");
    const headerTexts = Array.from(headerCells).map(cell => cell.textContent.trim());
    
    const bodyCells = table.querySelectorAll("tbody td");
    bodyCells.forEach((cell, index) => {
      const headerIndex = index % headerTexts.length;
      cell.setAttribute("data-label", headerTexts[headerIndex]);
    });
  });
}

// 폼 유효성 검사
function initFormValidation() {
  const forms = document.querySelectorAll("form");
  forms.forEach(form => {
    form.addEventListener("submit", function(e) {
      const requiredFields = form.querySelectorAll("[required]");
      let isValid = true;
      
      requiredFields.forEach(field => {
        if (!field.value.trim()) {
          isValid = false;
          field.classList.add("invalid");
          
          // 이미 에러 메시지가 있는지 확인
          const existingError = field.parentElement.querySelector(".field-error");
          if (!existingError) {
            const errorMsg = document.createElement("p");
            errorMsg.classList.add("field-error");
            errorMsg.textContent = "이 필드는 필수입니다.";
            field.insertAdjacentElement("afterend", errorMsg);
          }
        } else {
          field.classList.remove("invalid");
          const errorMsg = field.parentElement.querySelector(".field-error");
          if (errorMsg) errorMsg.remove();
        }
      });
      
      if (!isValid) {
        e.preventDefault();
        const firstInvalid = form.querySelector(".invalid");
        if (firstInvalid) firstInvalid.focus();
      }
    });
    
    // 입력 필드 이벤트 핸들러
    const inputFields = form.querySelectorAll("input, textarea, select");
    inputFields.forEach(field => {
      field.addEventListener("blur", function() {
        if (this.hasAttribute("required") && !this.value.trim()) {
          this.classList.add("invalid");
        } else {
          this.classList.remove("invalid");
          const errorMsg = this.parentElement.querySelector(".field-error");
          if (errorMsg) errorMsg.remove();
        }
      });
    });
  });
}

// 스크롤 효과 추가
function addScrollEffects() {
  const scrollElements = document.querySelectorAll(".course-card, .info-box, .form-container");
  
  function isElementInViewport(el) {
    const rect = el.getBoundingClientRect();
    return (
      rect.top <= (window.innerHeight || document.documentElement.clientHeight) * 0.8 &&
      rect.bottom >= 0
    );
  }
  
  function handleScrollAnimation() {
    scrollElements.forEach(el => {
      if (isElementInViewport(el)) {
        el.classList.add("show-element");
      }
    });
  }
  
  // 초기 로드 시 체크
  handleScrollAnimation();
  
  // 스크롤 시 체크
  window.addEventListener("scroll", handleScrollAnimation, { passive: true });
}

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
