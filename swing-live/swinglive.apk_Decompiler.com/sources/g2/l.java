package g2;

import X.N;
import e1.AbstractC0367g;
import java.io.ByteArrayOutputStream;

/* JADX INFO: loaded from: classes.dex */
public final class l extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AbstractC0367g f4376a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public j f4377b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public com.google.android.gms.common.internal.r f4378c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ByteArrayOutputStream f4379d;
    public byte[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4380f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f4381m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public /* synthetic */ Object f4382n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ N f4383o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f4384p;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public l(N n4, A3.c cVar) {
        super(cVar);
        this.f4383o = n4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4382n = obj;
        this.f4384p |= Integer.MIN_VALUE;
        return this.f4383o.f(null, null, 0, null, this);
    }
}
