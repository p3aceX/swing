package r2;

import java.util.Iterator;
import java.util.List;
import m1.C0553h;

/* JADX INFO: renamed from: r2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0654a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public List f6307a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0553h f6308b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Y3.a f6309c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Iterator f6310d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6311f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6312m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public /* synthetic */ Object f6313n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final /* synthetic */ i f6314o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f6315p;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0654a(i iVar, A3.c cVar) {
        super(cVar);
        this.f6314o = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6313n = obj;
        this.f6315p |= Integer.MIN_VALUE;
        return this.f6314o.a(null, null, this);
    }
}
