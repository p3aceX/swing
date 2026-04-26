package E0;

import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public abstract class c extends b implements A0.c {
    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        if (!getClass().isInstance(obj)) {
            return false;
        }
        b bVar = (b) obj;
        for (a aVar : getFieldMappings().values()) {
            if (isFieldSet(aVar)) {
                if (!bVar.isFieldSet(aVar) || !F.j(getFieldValue(aVar), bVar.getFieldValue(aVar))) {
                    return false;
                }
            } else if (bVar.isFieldSet(aVar)) {
                return false;
            }
        }
        return true;
    }

    @Override // E0.b
    public Object getValueObject(String str) {
        return null;
    }

    public int hashCode() {
        int iHashCode = 0;
        for (a aVar : getFieldMappings().values()) {
            if (isFieldSet(aVar)) {
                Object fieldValue = getFieldValue(aVar);
                F.g(fieldValue);
                iHashCode = (iHashCode * 31) + fieldValue.hashCode();
            }
        }
        return iHashCode;
    }

    @Override // E0.b
    public boolean isPrimitiveFieldSet(String str) {
        return false;
    }
}
