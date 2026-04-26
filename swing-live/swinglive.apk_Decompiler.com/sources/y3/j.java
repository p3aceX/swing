package Y3;

import V3.s;
import java.util.concurrent.atomic.AtomicReferenceArray;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class j extends s {
    public final /* synthetic */ AtomicReferenceArray e;

    public j(long j4, j jVar, int i4) {
        super(j4, jVar, i4);
        this.e = new AtomicReferenceArray(i.f2542f);
    }

    @Override // V3.s
    public final int g() {
        return i.f2542f;
    }

    @Override // V3.s
    public final void h(int i4, InterfaceC0767h interfaceC0767h) {
        this.e.set(i4, i.e);
        i();
    }

    public final String toString() {
        return "SemaphoreSegment[id=" + this.f2248c + ", hashCode=" + hashCode() + ']';
    }
}
