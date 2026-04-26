package I;

import java.io.Serializable;
import java.util.Iterator;

/* JADX INFO: renamed from: I.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0045f extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Serializable f651a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Iterator f652b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f653c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f654d;

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f653c = obj;
        this.f654d |= Integer.MIN_VALUE;
        return H0.a.b(null, null, this);
    }
}
