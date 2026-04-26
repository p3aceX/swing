package d0;

import android.os.Parcel;
import android.os.Parcelable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/* JADX INFO: renamed from: d0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0322a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final n.b f3883a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final n.b f3884b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final n.b f3885c;

    public AbstractC0322a(n.b bVar, n.b bVar2, n.b bVar3) {
        this.f3883a = bVar;
        this.f3884b = bVar2;
        this.f3885c = bVar3;
    }

    public abstract C0323b a();

    public final Class b(Class cls) throws ClassNotFoundException {
        String name = cls.getName();
        n.b bVar = this.f3885c;
        Class cls2 = (Class) bVar.getOrDefault(name, null);
        if (cls2 != null) {
            return cls2;
        }
        Class<?> cls3 = Class.forName(cls.getPackage().getName() + "." + cls.getSimpleName() + "Parcelizer", false, cls.getClassLoader());
        bVar.put(cls.getName(), cls3);
        return cls3;
    }

    public final Method c(String str) throws NoSuchMethodException {
        n.b bVar = this.f3883a;
        Method method = (Method) bVar.getOrDefault(str, null);
        if (method != null) {
            return method;
        }
        System.currentTimeMillis();
        Method declaredMethod = Class.forName(str, true, AbstractC0322a.class.getClassLoader()).getDeclaredMethod("read", AbstractC0322a.class);
        bVar.put(str, declaredMethod);
        return declaredMethod;
    }

    public final Method d(Class cls) throws NoSuchMethodException, ClassNotFoundException {
        String name = cls.getName();
        n.b bVar = this.f3884b;
        Method method = (Method) bVar.getOrDefault(name, null);
        if (method != null) {
            return method;
        }
        Class clsB = b(cls);
        System.currentTimeMillis();
        Method declaredMethod = clsB.getDeclaredMethod("write", cls, AbstractC0322a.class);
        bVar.put(cls.getName(), declaredMethod);
        return declaredMethod;
    }

    public abstract boolean e(int i4);

    public final Parcelable f(Parcelable parcelable, int i4) {
        if (!e(i4)) {
            return parcelable;
        }
        return ((C0323b) this).e.readParcelable(C0323b.class.getClassLoader());
    }

    public final InterfaceC0324c g() {
        String string = ((C0323b) this).e.readString();
        if (string == null) {
            return null;
        }
        try {
            return (InterfaceC0324c) c(string).invoke(null, a());
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("VersionedParcel encountered ClassNotFoundException", e);
        } catch (IllegalAccessException e4) {
            throw new RuntimeException("VersionedParcel encountered IllegalAccessException", e4);
        } catch (NoSuchMethodException e5) {
            throw new RuntimeException("VersionedParcel encountered NoSuchMethodException", e5);
        } catch (InvocationTargetException e6) {
            if (e6.getCause() instanceof RuntimeException) {
                throw ((RuntimeException) e6.getCause());
            }
            throw new RuntimeException("VersionedParcel encountered InvocationTargetException", e6);
        }
    }

    public abstract void h(int i4);

    public final void i(InterfaceC0324c interfaceC0324c) {
        if (interfaceC0324c == null) {
            ((C0323b) this).e.writeString(null);
            return;
        }
        try {
            ((C0323b) this).e.writeString(b(interfaceC0324c.getClass()).getName());
            C0323b c0323bA = a();
            try {
                d(interfaceC0324c.getClass()).invoke(null, interfaceC0324c, c0323bA);
                int i4 = c0323bA.f3890i;
                if (i4 >= 0) {
                    int i5 = c0323bA.f3886d.get(i4);
                    Parcel parcel = c0323bA.e;
                    int iDataPosition = parcel.dataPosition();
                    parcel.setDataPosition(i5);
                    parcel.writeInt(iDataPosition - i5);
                    parcel.setDataPosition(iDataPosition);
                }
            } catch (ClassNotFoundException e) {
                throw new RuntimeException("VersionedParcel encountered ClassNotFoundException", e);
            } catch (IllegalAccessException e4) {
                throw new RuntimeException("VersionedParcel encountered IllegalAccessException", e4);
            } catch (NoSuchMethodException e5) {
                throw new RuntimeException("VersionedParcel encountered NoSuchMethodException", e5);
            } catch (InvocationTargetException e6) {
                if (!(e6.getCause() instanceof RuntimeException)) {
                    throw new RuntimeException("VersionedParcel encountered InvocationTargetException", e6);
                }
                throw ((RuntimeException) e6.getCause());
            }
        } catch (ClassNotFoundException e7) {
            throw new RuntimeException(interfaceC0324c.getClass().getSimpleName().concat(" does not have a Parcelizer"), e7);
        }
    }
}
