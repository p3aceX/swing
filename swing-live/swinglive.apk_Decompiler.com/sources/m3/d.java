package M3;

import a.AbstractC0184a;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public class d implements Iterable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1095a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1096b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1097c;

    public d(int i4, int i5, int i6) {
        if (i6 == 0) {
            throw new IllegalArgumentException("Step must be non-zero.");
        }
        if (i6 == Integer.MIN_VALUE) {
            throw new IllegalArgumentException("Step must be greater than Int.MIN_VALUE to avoid overflow on negation.");
        }
        this.f1095a = i4;
        this.f1096b = AbstractC0184a.K(i4, i5, i6);
        this.f1097c = i6;
    }

    public boolean equals(Object obj) {
        if (!(obj instanceof d)) {
            return false;
        }
        if (isEmpty() && ((d) obj).isEmpty()) {
            return true;
        }
        d dVar = (d) obj;
        return this.f1095a == dVar.f1095a && this.f1096b == dVar.f1096b && this.f1097c == dVar.f1097c;
    }

    public int hashCode() {
        if (isEmpty()) {
            return -1;
        }
        return (((this.f1095a * 31) + this.f1096b) * 31) + this.f1097c;
    }

    public boolean isEmpty() {
        int i4 = this.f1097c;
        int i5 = this.f1096b;
        int i6 = this.f1095a;
        return i4 > 0 ? i6 > i5 : i6 < i5;
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new e(this.f1095a, this.f1096b, this.f1097c);
    }

    public String toString() {
        StringBuilder sb;
        int i4 = this.f1096b;
        int i5 = this.f1095a;
        int i6 = this.f1097c;
        if (i6 > 0) {
            sb = new StringBuilder();
            sb.append(i5);
            sb.append("..");
            sb.append(i4);
            sb.append(" step ");
            sb.append(i6);
        } else {
            sb = new StringBuilder();
            sb.append(i5);
            sb.append(" downTo ");
            sb.append(i4);
            sb.append(" step ");
            sb.append(-i6);
        }
        return sb.toString();
    }
}
