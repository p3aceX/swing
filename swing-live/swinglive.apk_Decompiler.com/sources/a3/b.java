package A3;

import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class b implements InterfaceC0762c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final b f86a = new b();

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        throw new IllegalStateException("This continuation is already complete");
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) {
        throw new IllegalStateException("This continuation is already complete");
    }

    public final String toString() {
        return "This continuation is already complete";
    }
}
