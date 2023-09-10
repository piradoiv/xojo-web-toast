"use strict";
var RC;
(function (RC) {
    class Toast extends XojoWeb.XojoControl {
        constructor() {
            super(...arguments);
            this.mWrapperElementID = 'bs-toast-wrapper';
            this.mToastWrapper = null;
        }
        updateControl(data) {
            const js = JSON.parse(data);
            const commands = JSON.parse(Toast.decode(js.commands));
            if (typeof commands === 'object' && commands.length > 0) {
                commands.forEach((command) => this.parseCommand(command));
            }
        }
        toast(title, timeAgo, body, autoHide = true, hideDelay = 500) {
            var _a, _b, _c;
            this.createWrapperIfNeeded();
            const element = document.createElement('div');
            (_a = this.mToastWrapper) === null || _a === void 0 ? void 0 : _a.appendChild(element);
            const toastId = 'bs-toast-' + Date.now();
            element.outerHTML =
                `
                <div id="${toastId}" class="toast" role="alert" aria-live="assertive" aria-atomic="true"
                    data-bs-animation="true" data-bs-autohide="${autoHide}" data-bs-delay="${hideDelay}">
                    <div class="toast-header">
                        <strong class="me-auto">${title}</strong>
                        <small class="text-body-secondary">${timeAgo}</small>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                    </div>
                    <div class="toast-body">${body}</div>
                </div>
                `.trim();
            if (!autoHide) {
                (_b = document.getElementById(toastId)) === null || _b === void 0 ? void 0 : _b.removeAttribute('data-bs-delay');
            }
            (_c = document.getElementById(toastId)) === null || _c === void 0 ? void 0 : _c.addEventListener('hidden.bs.toast', (ev) => {
                var _a;
                (_a = this.getToastById(toastId)) === null || _a === void 0 ? void 0 : _a.dispose();
                const target = ev.target;
                target.remove();
            });
            bootstrap.Toast.getOrCreateInstance(`#${toastId}`).show();
        }
        hideAt(index) {
            var _a;
            const elements = document.querySelectorAll(`#${this.mWrapperElementID} .toast`);
            if (index < elements.length) {
                (_a = bootstrap.Toast.getInstance(elements[index])) === null || _a === void 0 ? void 0 : _a.hide();
            }
        }
        hideAll() {
            document.querySelectorAll(`#${this.mWrapperElementID} .toast`)
                .forEach((element) => {
                var _a;
                (_a = bootstrap.Toast.getInstance(element)) === null || _a === void 0 ? void 0 : _a.hide();
            });
        }
        parseCommand(command) {
            switch (command.type) {
                case 'toast':
                    const title = command.title || '';
                    const timeAgo = command.time_ago || '';
                    const body = command.body || '';
                    let autoHide = true;
                    if (typeof command.auto_hide === 'boolean') {
                        autoHide = command.auto_hide;
                    }
                    const hideDelay = command.hide_delay || 2500;
                    this.toast(title, timeAgo, body, autoHide, hideDelay);
                    break;
                case 'hide-at':
                    command.index && this.hideAt(command.index);
                    break;
                case 'hide-all':
                    this.hideAll();
                    break;
            }
        }
        createWrapperIfNeeded() {
            var _a;
            this.mToastWrapper = document.getElementById(this.mWrapperElementID);
            if (this.mToastWrapper) {
                return;
            }
            this.mToastWrapper = document.createElement('div');
            this.mToastWrapper.id = this.mWrapperElementID;
            this.mToastWrapper.classList.add('toast-container', 'top-0', 'end-0', 'p-3');
            (_a = document.getElementById('XojoSession')) === null || _a === void 0 ? void 0 : _a.appendChild(this.mToastWrapper);
        }
        static decode(str) {
            return decodeURIComponent(atob(str));
        }
        getToastById(id) {
            return bootstrap.Toast.getInstance(id);
        }
    }
    RC.Toast = Toast;
})(RC || (RC = {}));
