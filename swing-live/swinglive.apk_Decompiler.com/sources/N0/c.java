package N0;

import M0.W;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A0.a {
    public static final Parcelable.Creator<c> CREATOR = new W(20);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final a f1108a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1109b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f1110c;

    static {
        new c("unavailable");
        new c("unused");
    }

    public c(String str) {
        this.f1109b = str;
        this.f1108a = a.STRING;
        this.f1110c = null;
    }

    public static a b(int i4) throws b {
        for (a aVar : a.values()) {
            if (i4 == aVar.f1107a) {
                return aVar;
            }
        }
        throw new b(B1.a.l("ChannelIdValueType ", i4, " not supported"));
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        a aVar = cVar.f1108a;
        a aVar2 = this.f1108a;
        if (!aVar2.equals(aVar)) {
            return false;
        }
        int iOrdinal = aVar2.ordinal();
        if (iOrdinal == 0) {
            return true;
        }
        if (iOrdinal == 1) {
            return this.f1109b.equals(cVar.f1109b);
        }
        if (iOrdinal != 2) {
            return false;
        }
        return this.f1110c.equals(cVar.f1110c);
    }

    public final int hashCode() {
        int i4;
        int iHashCode;
        a aVar = this.f1108a;
        int iHashCode2 = aVar.hashCode() + 31;
        int iOrdinal = aVar.ordinal();
        if (iOrdinal == 1) {
            i4 = iHashCode2 * 31;
            iHashCode = this.f1109b.hashCode();
        } else {
            if (iOrdinal != 2) {
                return iHashCode2;
            }
            i4 = iHashCode2 * 31;
            iHashCode = this.f1110c.hashCode();
        }
        return iHashCode + i4;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        int i5 = this.f1108a.f1107a;
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 3, this.f1109b, false);
        AbstractC0184a.i0(parcel, 4, this.f1110c, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public c(String str, int i4, String str2) {
        try {
            this.f1108a = b(i4);
            this.f1109b = str;
            this.f1110c = str2;
        } catch (b e) {
            throw new IllegalArgumentException(e);
        }
    }
}
