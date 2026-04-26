package B3;

import J3.i;
import java.io.Serializable;
import x3.AbstractC0723c;

/* JADX INFO: loaded from: classes.dex */
public final class b extends AbstractC0723c implements a, Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Enum[] f119a;

    public b(Enum[] enumArr) {
        i.e(enumArr, "entries");
        this.f119a = enumArr;
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection
    public final boolean contains(Object obj) {
        if (!(obj instanceof Enum)) {
            return false;
        }
        Enum r4 = (Enum) obj;
        i.e(r4, "element");
        int iOrdinal = r4.ordinal();
        Enum[] enumArr = this.f119a;
        i.e(enumArr, "<this>");
        return ((iOrdinal < 0 || iOrdinal >= enumArr.length) ? null : enumArr[iOrdinal]) == r4;
    }

    @Override // x3.AbstractC0723c
    public final int f() {
        return this.f119a.length;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        Enum[] enumArr = this.f119a;
        int length = enumArr.length;
        if (i4 < 0 || i4 >= length) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, length, ", size: "));
        }
        return enumArr[i4];
    }

    @Override // x3.AbstractC0723c, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Enum)) {
            return -1;
        }
        Enum r5 = (Enum) obj;
        i.e(r5, "element");
        int iOrdinal = r5.ordinal();
        Enum[] enumArr = this.f119a;
        i.e(enumArr, "<this>");
        if (((iOrdinal < 0 || iOrdinal >= enumArr.length) ? null : enumArr[iOrdinal]) == r5) {
            return iOrdinal;
        }
        return -1;
    }

    @Override // x3.AbstractC0723c, java.util.List
    public final int lastIndexOf(Object obj) {
        if (!(obj instanceof Enum)) {
            return -1;
        }
        Enum r5 = (Enum) obj;
        i.e(r5, "element");
        int iOrdinal = r5.ordinal();
        Enum[] enumArr = this.f119a;
        i.e(enumArr, "<this>");
        if (((iOrdinal < 0 || iOrdinal >= enumArr.length) ? null : enumArr[iOrdinal]) == r5) {
            return iOrdinal;
        }
        return -1;
    }
}
