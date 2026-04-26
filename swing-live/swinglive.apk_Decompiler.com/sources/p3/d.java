package P3;

import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
public final class d implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1501a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1502b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f1503c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1504d;
    public int e;

    public d(String str) {
        J3.i.e(str, "string");
        this.f1501a = str;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        int i4;
        int i5;
        int i6 = this.f1502b;
        if (i6 != 0) {
            return i6 == 1;
        }
        if (this.e < 0) {
            this.f1502b = 2;
            return false;
        }
        String str = this.f1501a;
        int length = str.length();
        int length2 = str.length();
        for (int i7 = this.f1503c; i7 < length2; i7++) {
            char cCharAt = str.charAt(i7);
            if (cCharAt == '\n' || cCharAt == '\r') {
                i4 = (cCharAt == '\r' && (i5 = i7 + 1) < str.length() && str.charAt(i5) == '\n') ? 2 : 1;
                length = i7;
                this.f1502b = 1;
                this.e = i4;
                this.f1504d = length;
                return true;
            }
        }
        i4 = -1;
        this.f1502b = 1;
        this.e = i4;
        this.f1504d = length;
        return true;
    }

    @Override // java.util.Iterator
    public final Object next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        this.f1502b = 0;
        int i4 = this.f1504d;
        int i5 = this.f1503c;
        this.f1503c = this.e + i4;
        return this.f1501a.subSequence(i5, i4).toString();
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }
}
