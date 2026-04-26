package io.ktor.utils.io;

/* JADX INFO: renamed from: io.ktor.utils.io.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0437a implements InterfaceC0443g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Throwable f4968b;

    public C0437a(Throwable th) {
        this.f4968b = th;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        return (obj instanceof C0437a) && J3.i.a(this.f4968b, ((C0437a) obj).f4968b);
    }

    public final int hashCode() {
        Throwable th = this.f4968b;
        if (th == null) {
            return 0;
        }
        return th.hashCode();
    }

    public final String toString() {
        return "Closed(cause=" + this.f4968b + ')';
    }
}
