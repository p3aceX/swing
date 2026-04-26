package Q3;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: renamed from: Q3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0125e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1620b = AtomicIntegerFieldUpdater.newUpdater(C0125e.class, "notCompletedCount$volatile");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final I[] f1621a;
    private volatile /* synthetic */ int notCompletedCount$volatile;

    public C0125e(I[] iArr) {
        this.f1621a = iArr;
        this.notCompletedCount$volatile = iArr.length;
    }
}
