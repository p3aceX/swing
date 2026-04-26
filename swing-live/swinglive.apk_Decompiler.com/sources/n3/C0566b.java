package n3;

import java.nio.channels.Selector;

/* JADX INFO: renamed from: n3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0566b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public m f5894a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Selector f5895b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f5896c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ e f5897d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0566b(e eVar, A3.c cVar) {
        super(cVar);
        this.f5897d = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5896c = obj;
        this.e |= Integer.MIN_VALUE;
        return e.a(this.f5897d, null, null, this);
    }
}
