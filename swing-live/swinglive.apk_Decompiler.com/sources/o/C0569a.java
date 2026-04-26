package o;

import java.util.concurrent.CancellationException;

/* JADX INFO: renamed from: o.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0569a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0569a f5937c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0569a f5938d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f5939a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CancellationException f5940b;

    static {
        if (AbstractFutureC0576h.f5951d) {
            f5938d = null;
            f5937c = null;
        } else {
            f5938d = new C0569a(false, null);
            f5937c = new C0569a(true, null);
        }
    }

    public C0569a(boolean z4, CancellationException cancellationException) {
        this.f5939a = z4;
        this.f5940b = cancellationException;
    }
}
