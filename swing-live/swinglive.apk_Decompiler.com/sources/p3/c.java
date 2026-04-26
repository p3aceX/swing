package P3;

import I3.p;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class c implements O3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final CharSequence f1499a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final p f1500b;

    public c(CharSequence charSequence, p pVar) {
        J3.i.e(charSequence, "input");
        this.f1499a = charSequence;
        this.f1500b = pVar;
    }

    @Override // O3.c
    public final Iterator iterator() {
        return new b(this);
    }
}
