package T3;

import S3.u;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public u f2020a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f2021b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ c f2022c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2023d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(c cVar, A3.c cVar2) {
        super(cVar2);
        this.f2022c = cVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f2021b = obj;
        this.f2023d |= Integer.MIN_VALUE;
        return this.f2022c.a(null, this);
    }
}
