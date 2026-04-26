package I;

import java.io.FileOutputStream;

/* JADX INFO: loaded from: classes.dex */
public final class a0 extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public FileOutputStream f636a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public FileOutputStream f637b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f638c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ b0 f639d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a0(b0 b0Var, A3.c cVar) {
        super(cVar);
        this.f639d = b0Var;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f638c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f639d.b(null, this);
    }
}
