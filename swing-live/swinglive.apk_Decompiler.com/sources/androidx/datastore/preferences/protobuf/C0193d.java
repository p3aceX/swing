package androidx.datastore.preferences.protobuf;

import com.google.crypto.tink.shaded.protobuf.C0302g;
import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0193d implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2961a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2962b = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f2963c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Object f2964d;

    public C0193d(C0196g c0196g) {
        this.f2964d = c0196g;
        this.f2963c = c0196g.size();
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        switch (this.f2961a) {
            case 0:
                if (this.f2962b < this.f2963c) {
                }
                break;
            default:
                if (this.f2962b < this.f2963c) {
                }
                break;
        }
        return false;
    }

    @Override // java.util.Iterator
    public final Object next() {
        switch (this.f2961a) {
            case 0:
                int i4 = this.f2962b;
                if (i4 >= this.f2963c) {
                    throw new NoSuchElementException();
                }
                this.f2962b = i4 + 1;
                return Byte.valueOf(((C0196g) this.f2964d).k(i4));
            default:
                int i5 = this.f2962b;
                if (i5 >= this.f2963c) {
                    throw new NoSuchElementException();
                }
                this.f2962b = i5 + 1;
                return Byte.valueOf(((C0302g) this.f2964d).l(i5));
        }
    }

    @Override // java.util.Iterator
    public final void remove() {
        switch (this.f2961a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                throw new UnsupportedOperationException();
        }
    }

    public C0193d(C0302g c0302g) {
        this.f2964d = c0302g;
        this.f2963c = c0302g.size();
    }
}
