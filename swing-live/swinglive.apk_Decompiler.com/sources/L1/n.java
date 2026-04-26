package l1;

import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final class n implements InterfaceC0634a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Object f5615c = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile Object f5616a = f5615c;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public volatile InterfaceC0634a f5617b;

    public n(InterfaceC0634a interfaceC0634a) {
        this.f5617b = interfaceC0634a;
    }

    @Override // q1.InterfaceC0634a
    public final Object get() {
        Object obj;
        Object obj2 = this.f5616a;
        Object obj3 = f5615c;
        if (obj2 != obj3) {
            return obj2;
        }
        synchronized (this) {
            try {
                obj = this.f5616a;
                if (obj == obj3) {
                    obj = this.f5617b.get();
                    this.f5616a = obj;
                    this.f5617b = null;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return obj;
    }
}
