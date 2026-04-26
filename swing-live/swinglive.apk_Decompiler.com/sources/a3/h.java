package A3;

import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class h extends a {
    public h(InterfaceC0762c interfaceC0762c) {
        super(interfaceC0762c);
        if (interfaceC0762c != null && interfaceC0762c.getContext() != C0768i.f6945a) {
            throw new IllegalArgumentException("Coroutines with restricted suspension must have EmptyCoroutineContext");
        }
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return C0768i.f6945a;
    }
}
