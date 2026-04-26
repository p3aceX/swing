package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: renamed from: Q3.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0149v {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1665b = AtomicIntegerFieldUpdater.newUpdater(C0149v.class, "_handled$volatile");
    private volatile /* synthetic */ int _handled$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Throwable f1666a;

    public C0149v(Throwable th, boolean z4) {
        this.f1666a = th;
        this._handled$volatile = z4 ? 1 : 0;
    }

    public final String toString() {
        return getClass().getSimpleName() + '[' + this.f1666a + ']';
    }
}
