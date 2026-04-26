package M3;

import a.AbstractC0184a;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public abstract class a implements Iterable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final char f1088a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final char f1089b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1090c = 1;

    public a(char c5, char c6) {
        this.f1088a = c5;
        this.f1089b = (char) AbstractC0184a.K(c5, c6, 1);
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new b(this.f1088a, this.f1089b, this.f1090c);
    }
}
