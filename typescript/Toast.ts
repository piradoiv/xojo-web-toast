interface ToastCommand {
    type: string;
    title?: string;
    time_ago?: string;
    body?: string;
    auto_hide?: boolean;
    hide_delay?: number;
    index?: number;
    indicator?: number;
}

namespace RC {
    export class Toast extends XojoWeb.XojoControl {
        private mWrapperElementID: string = 'bs-toast-wrapper';
        private mToastWrapper: HTMLDivElement | null = null;

        updateControl(data: string) {
            const js = JSON.parse(data);
            const commands = JSON.parse(Toast.decode(js.commands));
            if (typeof commands === 'object' && commands.length > 0) {
                commands.forEach((command: ToastCommand) => this.parseCommand(command));
            }
        }

        toast(title: string, timeAgo: string, body: string, autoHide: boolean = true, hideDelay: number = 500, indicator: number = 0) {
            this.createWrapperIfNeeded();
            const element = document.createElement('div');
            this.mToastWrapper?.appendChild(element);
            const toastId = 'bs-toast-' + Date.now();

            const indicators = ['light', 'primary', 'secondary', 'success', 'danger', 'warning', 'info', 'dark', 'light'];
            // @ts-ignore
            if (XojoWeb.session.isDarkModeEnabled) {
                indicators[0] = 'dark';
            }
            const indicatorString = `text-bg-${indicators[indicator]}`;

            // The HTML template is coming almost verbatim from Bootstrap's documentation:
            // https://getbootstrap.com/docs/5.3/components/toasts/
            element.outerHTML =
                `
                <div id="${toastId}" class="toast ${indicatorString}" role="alert" aria-live="assertive" aria-atomic="true"
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
                document.getElementById(toastId)?.removeAttribute('data-bs-delay');
            }

            document.getElementById(toastId)?.addEventListener('hidden.bs.toast', (ev) => {
                this.getToastById(toastId)?.dispose();
                const target = <HTMLDivElement>ev.target
                target.remove();
            });

            bootstrap.Toast.getOrCreateInstance(`#${toastId}`).show();
        }

        hideAt(index: number) {
            const elements = document.querySelectorAll(`#${this.mWrapperElementID} .toast`);
            if (index < elements.length) {
                bootstrap.Toast.getInstance(elements[index])?.hide();
            }
        }

        hideAll() {
            document.querySelectorAll(`#${this.mWrapperElementID} .toast`)
                .forEach((element) => {
                    bootstrap.Toast.getInstance(element)?.hide();
                });
        }

        private parseCommand(command: ToastCommand) {
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
                    const indicator = command.indicator || 0;
                    this.toast(title, timeAgo, body, autoHide, hideDelay, indicator);
                    break;
                case 'hide-at':
                    command.index && this.hideAt(command.index);
                    break;
                case 'hide-all':
                    this.hideAll();
                    break;
            }
        }

        private createWrapperIfNeeded() {
            this.mToastWrapper = <HTMLDivElement>document.getElementById(this.mWrapperElementID);
            if (this.mToastWrapper) {
                return;
            }

            this.mToastWrapper = document.createElement('div');
            this.mToastWrapper.id = this.mWrapperElementID;
            this.mToastWrapper.classList.add('toast-container', 'top-0', 'end-0', 'p-3');
            document.getElementById('XojoSession')?.appendChild(this.mToastWrapper);
        }

        private static decode(str: string): string {
            return decodeURIComponent(atob(str));
        }

        private getToastById(id: string): bootstrap.Toast | null {
            return bootstrap.Toast.getInstance(id);
        }
    }
}
