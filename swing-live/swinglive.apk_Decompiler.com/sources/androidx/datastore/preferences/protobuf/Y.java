package androidx.datastore.preferences.protobuf;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class Y implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2948a = -1;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f2949b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Iterator f2950c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ W f2951d;

    public Y(W w4) {
        this.f2951d = w4;
    }

    public final Iterator a() {
        if (this.f2950c == null) {
            this.f2950c = this.f2951d.f2942b.entrySet().iterator();
        }
        return this.f2950c;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        int i4 = this.f2948a + 1;
        W w4 = this.f2951d;
        return i4 < w4.f2941a.size() || (!w4.f2942b.isEmpty() && a().hasNext());
    }

    @Override // java.util.Iterator
    public final Object next() {
        this.f2949b = true;
        int i4 = this.f2948a + 1;
        this.f2948a = i4;
        W w4 = this.f2951d;
        return i4 < w4.f2941a.size() ? (Map.Entry) w4.f2941a.get(this.f2948a) : (Map.Entry) a().next();
    }

    @Override // java.util.Iterator
    public final void remove() {
        if (!this.f2949b) {
            throw new IllegalStateException("remove() was called before next()");
        }
        this.f2949b = false;
        int i4 = W.f2940f;
        W w4 = this.f2951d;
        w4.b();
        if (this.f2948a >= w4.f2941a.size()) {
            a().remove();
            return;
        }
        int i5 = this.f2948a;
        this.f2948a = i5 - 1;
        w4.h(i5);
    }
}
